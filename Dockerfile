# Start from the official PHP 8.2 FPM image.
FROM php:8.2-fpm

# Update the package lists and upgrade the installed packages.
RUN apt-get update && \
    apt-get upgrade -y

# Install the required libraries and PHP extensions.
RUN apt-get install -y --no-install-recommends \
    wget \
    libxml2-dev libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libpq-dev \
    libzip-dev \
    zlib1g-dev \
    graphicsmagick

RUN docker-php-ext-configure gd --with-libdir=/usr/include/ --with-jpeg --with-freetype && \
    docker-php-ext-install -j$(nproc) mysqli soap gd zip opcache intl pgsql pdo_pgsql

# Clean up the apt cache and remove unnecessary packages.
RUN apt-get clean && \
    apt-get -y purge \
    libxml2-dev libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libzip-dev \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/* /usr/src/*

# Set the working directory for the following instructions.
WORKDIR /var/www/html

# Download typo3_src and extract it.
#  https://get.typo3.org/12.4.2 
RUN wget -qO- https://get.typo3.org/12.4.2 | tar -xzf - --strip-components=1

# Change the owner and permissions of the TYPO3 files.
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install the PHP dependencies specified in the composer.json file.
RUN composer install