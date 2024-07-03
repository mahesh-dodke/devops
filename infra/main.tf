provider "google" {
  credentials = var.google_credentials
  project     = var.project_id
  region      = var.region
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
    ports    = ["80", "8000", "9000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_instance" "app_instance" {
  count        = var.feature_branch != "" ? 1 : 0
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
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg-agent \
      software-properties-common

    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
    add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/debian \
      $(lsb_release -cs) \
      stable"

    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io

    docker run -d -p 80:80 ${var.docker_image}
  EOF

  tags = ["http-server"]
}

resource "google_compute_address" "ip_address" {
  name = "${var.branch}-ip"
}

resource "google_dns_record_set" "dns_record" {
  name         = "${local.domain_name}"
  type         = "A"
  ttl          = 300
  managed_zone = var.dns_zone

  rrdatas = [google_compute_address.ip_address.address]
}

output "instance_ip" {
  value = google_compute_address.ip_address.address
}

output "domain_names" {
  value = "${local.domain_name}"
}
