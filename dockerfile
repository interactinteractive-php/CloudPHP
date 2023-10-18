# Use the official PHP 7.4-FPM image as the base
FROM php:7.4-fpm

# Install required packages and dependencies
RUN apt-get update && apt-get install -y \
    git \
    openssh-client


# Create a directory for your PHP application
WORKDIR /var/www/html

# Install additional PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libmcrypt-dev \
    libxml2-dev \
    libssl-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libcurl4-openssl-dev \
    libmariadb-dev-compat \
    libonig-dev \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        mbstring \
        pdo \
        soap \
        xml \
        gd \
        opcache \
        zip \
        mysqli \
    && pecl install mcrypt-1.0.4 \
    && docker-php-ext-enable mcrypt

RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    git \
    openssh-client
# Create user
RUN useradd -r -u 1001 -g 0 php

# Set up SSH key for ERP
RUN mkdir -p /root/.ssh
COPY /erp/id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa

# Clone your private ERP
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN git clone git@github.com:interactinteractive-php/php_erp.git /var/www/html/
RUN rm /root/.ssh/id_rsa

# Set up SSH key for AssetsCore
RUN mkdir -p /root/.ssh
COPY /assetscore/id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa

# Clone your private AssetsCore
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN git clone git@github.com:interactinteractive-php/php_assetscore.git /var/www/html/assetscore/
RUN rm /root/.ssh/id_rsa

# Set up SSH key for Helper
RUN mkdir -p /root/.ssh
COPY /helper/id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa

# Clone your private Helper
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN git clone git@github.com:interactinteractive-php/php_helper.git /var/www/html/helper/
RUN rm /root/.ssh/id_rsa

# Set up SSH key for Libs
RUN mkdir -p /root/.ssh
COPY /libs/id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa

# Clone your private Libs
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN git clone git@github.com:interactinteractive-php/php_libs.git /var/www/html/libs/
RUN rm /root/.ssh/id_rsa

# Set up SSH key for Middleware
RUN mkdir -p /root/.ssh
COPY /middleware/id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa

# Clone your private Middleware
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN git clone git@github.com:interactinteractive-php/php_middleware.git /var/www/html/middleware/
RUN rm /root/.ssh/id_rsa
RUN mkdir /var/www/html/config
COPY config.php /var/www/html/config/config.php
# Set all ENV variables

ENV URL_PROTOCOL="https"
ENV URL="example.com"
ENV DIRECTORY_SEPARATOR="/"
ENV GF_SERVICE_ADDRESS="localhost"
ENV SERVICE_FULL_ADDRESS="http://localhost:8080"
ENV CACHE_PATH="/var/cache"
ENV DB_HOST="db.example.com"
ENV DB_NAME="mydatabase"
ENV DB_USER="dbuser"
ENV DB_PASS="dbpassword"
ENV DB_SID="dbsid"
ENV DB_DRIVER="mysql"
ENV SESSION_PREFIX="mysession"
ENV SESSION_LIFETIME="3600"
ENV CONFIG_TIMEZONE="UTC"
ENV CONFIG_META_IMPORT="enabled"
ENV SMTP_HOST="smtp.example.com"
ENV SMTP_PORT="587"
ENV SMTP_USER="smtpuser"
ENV SMTP_PASS="smtppassword"
ENV SMTP_SECURE="tls"
ENV SMTP_AUTH="true"
ENV SMTP_SSL_VERIFY="true"
ENV EMAIL_FROM="you@example.com"
ENV EMAIL_FROM_NAME="Your Name"
ENV CONFIG_FILE_VIEWER_ADDRESS="http://fileviewer.example.com"
# Expose port for PHP-FPM
EXPOSE 9000

# Set user
USER www-data

# Start PHP-FPM
CMD ["php-fpm"]
