# apache-laravel

Setup Laravel with Apache server and MySQL database on your domain.

## Apache Installation

### Step 1: Install Apache

```bash
sudo apt update
sudo apt install apache2
```

### Step 2: Verify Apache Installation

Check if Apache is running:

````bash
sudo systemctl status apache2
If Apache is not running, start it:

```bash
sudo systemctl start apache2
````

### Step 3: Configure Apache to Start on Boot

To ensure Apache starts automatically on server boot:

```bash
sudo systemctl enable apache2
```

## Setup Laravel

## Configure Apache

To configure Apache to serve a website based on a domain name, you'll need to set up a Virtual Host. Here's how you can do it on Ubuntu:

### Step 1: Enable the rewrite module (optional but recommended)

This module allows URL rewriting, which is often needed for domain-based routing.

```bash
sudo a2enmod rewrite
sudo systemctl restart apache2
```

### Step 2: Create a Virtual Host Configuration File

#### Navigate to the sites-available directory:

```bash
cd /etc/apache2/sites-available/
```

#### Create a new configuration file for your domain:

-   #### Replace yourdomain.com with your actual domain name.

```bash
sudo nano yourdomain.com.conf
```

-   #### Add the following content to the file:

```apache
<VirtualHost *:80>
    ServerName apache-laravel.bimash.com.np

    ProxyPass /  http://localhost:8000/
    ProxyPassReverse /  http://localhost:8000/

    <Proxy *>
        Require all granted
    </Proxy>

    # Optional: Log directives for debugging
    ErrorLog ${APACHE_LOG_DIR}/proxy_error.log
    CustomLog ${APACHE_LOG_DIR}/proxy_access.log combined
</VirtualHost>

```

-   #### Enable Required Apache Modules

```bash
sudo a2enmod proxy
sudo a2enmod proxy_http
```

-   #### Save and Enable the Virtual Host

```bash
sudo a2ensite apache-laravel.bimash.com.np.conf
```

### Step 3: Disable Conflicting Sites

If there’s a default site that could conflict, disable it:

```bash
sudo a2dissite 000-default.conf
```

### Step 4: Reload Apache

Apply the configuration changes by reloading Apache:

```bash
sudo systemctl reload apache2
```

### Step 5: Check DNS

Ensure that the DNS for apache-laravel.bimash.com.np points to your server’s IP address.

### Step 6: Test the Configuration

Open a web browser and go to http://yourdomain.com. You should see the "Welcome to yourdomain.com" message you added in the index.html file.
If you need to use SSL (HTTPS), you can obtain and configure an SSL certificate using Let's Encrypt with Certbot. This is often required for modern web standards.

## Manual Deployment

### Step 1: Pull the Latest Changes

Navigate to your Laravel project directory and pull the latest changes:

```bash
cd /path/to/your/apache-laravel/
git pull origin main
```

Adjust the branch name (main in this case) as needed.

### Step 2: Run Docker Compose

If you're using Docker Compose, restart the containers:

```bash
    docker compose down
    docker compose build
    docker compose up -d
```

### Step 3: Go to Docker Container

If you're using Docker, you might need to go into the container to run commands:

```bash
    docker exec -it dockerApp bash
```

### Step 4: Clear Laravel Cache

Clear the Laravel cache to apply any configuration changes:

```bash
composer update
php artisan config:cache
php artisan route:cache
php artisan view:clear
```

### Step 3: Migrate Database

If you've made changes to the database schema, run the migration:

```bash
php artisan migrate
```

### Step 4: Verify Changes

After reloading Apache and clearing the Laravel cache, visit your application’s URL to verify that the changes have been applied correctly.

## CI/CD Pipeline Deployment

```yaml
name: 🚀 Deploy Docker Laravel
on:
    push:
        branches:
            - main

jobs:
    web-deploy:
        name: 🎉 Deploy
        runs-on: ubuntu-latest

        steps:
            - name: Checkout code
              uses: actions/checkout@v2

            - name: Set up PHP
              uses: shivammathur/setup-php@v2
              with:
                  php-version: "8.1.2"

            - name: Install Composer dependencies
              run: composer install --no-interaction --no-suggest

            - name: Set up SSH
              uses: webfactory/ssh-agent@v0.7.0
              with:
                  ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}

            - name: Deploy to Azure VM
              run: |
                  ssh -o StrictHostKeyChecking=no azureuser@20.51.207.28 << 'EOF'
                  cd apache/apache-laravel/
                  git pull origin main || { echo 'Git pull failed'; exit 1; }
                  docker-compose down
                  docker-compose build
                  docker-compose up -d
                  composer install --no-interaction --no-suggest
                  php artisan config:cache
                  php artisan route:cache
                  php artisan view:clear
                  EOF
```
