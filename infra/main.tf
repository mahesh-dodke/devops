provider "google" {
  credentials = var.google_credentials
  project     = var.project_id
  region      = var.region
  zone        = "${var.region}-b"
}

# Function to determine the domain based on the branch
locals {
  domain_name = var.feature_branch != "" ? "${var.commit_hash}.${var.domain}" : var.branch == "main" ? var.domain : "${var.branch}.${var.domain}"
}

resource "google_compute_firewall" "default" {
  name    = "allow-http-ports"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_instance" "app_instance" {
  count        = 1
  name         = "${var.feature_branch != "" ? "feature-${var.feature_branch}-${var.commit_hash}" : var.branch}-instance"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.ip_address.address
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e

    apt-get update
    apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg \
      lsb-release \
      software-properties-common

    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo \
      "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io

    systemctl start docker
    systemctl enable docker

    docker run -d -p 80:80 ${var.docker_image}

    # Logging for debugging
    echo "Docker installation and container setup completed" >> /var/log/startup-script.log
    docker ps >> /var/log/startup-script.log
  EOF

  tags = ["http-server"]
}

resource "google_compute_address" "ip_address" {
  name = "${var.branch}-ip"
}

resource "google_dns_record_set" "dns_record" {
  name         = "${local.domain_name}."
  type         = "A"
  ttl          = 300
  managed_zone = var.dns_zone

  rrdatas = [google_compute_address.ip_address.address]
}

output "instance_ip" {
  value = google_compute_address.ip_address.address
}

