#!/bin/bash

# Generate a random site name (you can modify this as needed)
SITE_NAME="site_$(date +%Y%m%d_%H%M%S)"
SITE_PATH="$HOME/docker-data/$SITE_NAME"
DB_PREFIX="${SITE_NAME}_"

# Create directory and navigate to it
mkdir -p "$SITE_PATH"
cd "$SITE_PATH"

# Create docker-compose file for this site
cat > docker-compose.yml << EOL
version: '3'
services:
  db:
    image: mysql:latest
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: 5B6ErWXS
      MYSQL_DATABASE: wordpress
    ports:
      - '3306:3306'
  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    restart: always
    ports:
      - '80:80'
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: root
      WORDPRESS_DB_PASSWORD: 5B6ErWXS
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - '$SITE_PATH:/var/www/html'
  wp-cli:
    image: wordpress:cli
    depends_on:
      - wordpress
    volumes:
      - '$SITE_PATH:/var/www/html'
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: root
      WORDPRESS_DB_PASSWORD: 5B6ErWXS
      WORDPRESS_DB_NAME: wordpress
EOL

# Start the containers
docker-compose up -d

# Wait for WordPress to be ready
sleep 30

# Download WordPress core
docker-compose run --rm wp-cli wp core download

# Create wp-config.php
docker-compose run --rm wp-cli wp config create \
    --dbname=wordpress \
    --dbuser=root \
    --dbpass=5B6ErWXS \
    --dbhost=db:3306 \
    --dbprefix=$DB_PREFIX

# Install WordPress
docker-compose run --rm wp-cli wp core install \
    --url="http://localhost" \
    --title="$SITE_NAME" \
    --admin_user=admin \
    --admin_password=admin123 \
    --admin_email="admin@example.com"

# Log the creation
echo "WordPress site created at $SITE_PATH at $(date)" >> "$HOME/docker-data/wp-sites.log" 