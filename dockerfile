FROM php:7.1-fpm

RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
            curl \
            libmemcached-dev \
            libz-dev \
            libpq-dev \
            libjpeg-dev \
            libpng-dev \
            libfreetype6-dev \
            libssl-dev \
            libwebp-dev \
            libmcrypt-dev; \
    # cleanup
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    # Install the PHP mcrypt extention
    docker-php-ext-install mcrypt; \
    # Install the PHP pdo_mysql extention
    docker-php-ext-install pdo_mysql; \
    # Install the PHP pdo_pgsql extention
    docker-php-ext-install pdo_pgsql; \
    # Install the PHP gd library
    docker-php-ext-configure gd \
            --enable-gd-native-ttf \
            --with-jpeg-dir=/usr/lib \
            --with-webp-dir=/usr/lib \
            --with-freetype-dir=/usr/include/freetype2; \
    docker-php-ext-install gd; \
    php -r 'var_dump(gd_info());'




# Set the working directory in the container
WORKDIR /var/www/html

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy the application code to the container
COPY . .

# Install application dependencies
RUN composer install --no-interaction --no-scripts --no-suggest

# Set the permissions for storage and bootstrap/cache directories
RUN chown -R www-data:www-data storage bootstrap/cache

# Generate the application key
RUN php artisan key:generate

# Expose port 80 for web server
EXPOSE 80

# Start the web server
CMD ["php", "-S", "0.0.0.0:80", "-t", "public"]