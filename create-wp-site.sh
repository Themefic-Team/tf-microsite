#!/bin/bash

# Generate a random site name (you can modify this as needed)
SITE_NAME="site_$(date +%Y%m%d_%H%M%S)"
SITE_PATH="$HOME/docker-data/$SITE_NAME"
DB_PREFIX="${SITE_NAME}_"

# Create directory for the new site
mkdir -p "$SITE_PATH"
cd "$SITE_PATH"

# Download WordPress core
docker-compose -f "$HOME/docker-data/docker-compose.yml" run --rm wp-cli wp core download --path="$SITE_PATH"

# Create wp-config.php
docker-compose -f "$HOME/docker-data/docker-compose.yml" run --rm wp-cli wp config create \
    --path="$SITE_PATH" \
    --dbname=wordpress \
    --dbuser=root \
    --dbpass=5B6ErWXS \
    --dbhost=db:3306 \
    --dbprefix=$DB_PREFIX

# Install WordPress
docker-compose -f "$HOME/docker-data/docker-compose.yml" run --rm wp-cli wp core install \
    --path="$SITE_PATH" \
    --url="http://ec2-34-227-194-37.compute-1.amazonaws.com/$SITE_NAME" \
    --title="$SITE_NAME" \
    --admin_user=admin \
    --admin_password=admin123 \
    --admin_email="admin@example.com"

# Log the creation
echo "WordPress site created at $SITE_PATH at $(date)" >> "$HOME/docker-data/wp-sites.log" 