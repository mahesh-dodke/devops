# Base Image
FROM php:8.1-apache

# Set working directory
WORKDIR /var/www/html

# Copy the current directory contents into the container at /var/www/html
COPY . .

RUN apt-get update && apt-get install -y software-properties-common zip unzip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install dependencies
RUN composer install

# Enable required Apache modules
RUN a2enmod rewrite
