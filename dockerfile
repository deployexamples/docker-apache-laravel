FROM php:7.1-fpm

RUN apt-get update -y && apt-get install -y openssl zip unzip git
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN docker-php-ext-install pdo mbstring
WORKDIR /app
COPY . /app
RUN composer install

# Expose port 80 for web server
EXPOSE 80

# Start the web server
CMD ["php", "-S", "0.0.0.0:80", "-t", "public"]