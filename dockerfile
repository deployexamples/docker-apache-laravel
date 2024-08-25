# Use the official PHP 7.1.3 image as the base image
FROM php:7.1.3

# Set the working directory in the container
WORKDIR /var/www/html

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

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