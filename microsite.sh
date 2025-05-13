#!/bin/bash

# Set proper PATH for cron execution
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"

# Variables
MainDir="/srv/www/wordpress"
LOG_FILE="/var/log/wordpress-sites.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Function to check if WordPress is installed
check_wordpress_installed() {
    local path="$1"
    if [ -f "$path/wp-config.php" ] || [ -f "$path/wp-login.php" ]; then
        return 0  # WordPress is installed
    else
        return 1  # WordPress is not installed
    fi
}

# Function to log site information
log_site_info() {
    local site_path="$1"
    local admin_user="$2"
    local admin_password="$3"
    local site_url="$4"
    
    {
        echo "=== New WordPress Site Created at $TIMESTAMP ==="
        echo "Site Path: $site_path"
        echo "Admin Username: $admin_user"
        echo "Admin Password: $admin_password"
        echo "Site URL: $site_url"
        echo "=============================================="
        echo ""
    } >> "$LOG_FILE"
}

# Source environment variables if .env exists
if [ -f "$(dirname "$0")/.env" ]; then
    source "$(dirname "$0")/.env"
else
    echo "Error: .env file not found"
    exit 1
fi

random_name() {
    length=${1:-8}
    characters="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    random_string=""

    for i in $(seq 1 $length); do
        random_index=$((RANDOM % ${#characters}))
        random_string+="${characters:$random_index:1}"
    done

    echo "$random_string"
}

create_directory() {
    dir_name=$(random_name)
    full_path="$MainDir/$dir_name"
    
    # Check if directory exists and has WordPress
    if [ -d "$full_path" ]; then
        if check_wordpress_installed "$full_path"; then
            echo "Error: WordPress already installed in $full_path"
            return 1
        fi
    fi
    
    # Create directory and ensure it exists
    mkdir -p "$full_path"
    if [ ! -d "$full_path" ]; then
        echo "Error: Failed to create directory $full_path"
        return 1
    fi
    
    # Change to directory and verify
    cd "$full_path" || {
        echo "Error: Failed to change to directory $full_path"
        return 1
    }
    
    echo "$full_path"
}

# Try to create directory until we find an empty one
max_attempts=5
attempt=1
site_path=""

while [ $attempt -le $max_attempts ]; do
    echo "Attempt $attempt to create directory..."
    site_path=$(create_directory)
    if [ $? -eq 0 ] && [ -n "$site_path" ]; then
        break
    fi
    attempt=$((attempt + 1))
    sleep 2
done

if [ -z "$site_path" ]; then
    echo "Error: Failed to create a valid site directory after $max_attempts attempts"
    exit 1
fi

# Check for WP-CLI with full path
WP_CLI=$(which wp 2>/dev/null)
if [ -z "$WP_CLI" ]; then
    # Try common WP-CLI locations
    for path in "/usr/local/bin/wp" "/usr/bin/wp" "/opt/wp-cli/wp"; do
        if [ -x "$path" ]; then
            WP_CLI="$path"
            break
        fi
    done
fi

if [ -n "$WP_CLI" ]; then
    echo "Using WP-CLI at: $WP_CLI"
    
    # Generate random values for site setup
    admin_user=$(random_name)
    admin_password="$(random_name)@9448"
    site_url="$WORDPRESS_URL/$(basename "$site_path")"
    
    # Double check WordPress is not installed before proceeding
    if check_wordpress_installed "$site_path"; then
        echo "Error: WordPress files detected in $site_path. Aborting installation."
        exit 1
    fi
    
    "$WP_CLI" core download --allow-root
    sleep 30
    "$WP_CLI" config create --dbname="$WORDPRESS_DB_NAME" --dbuser="$WORDPRESS_DB_USER" --dbpass="$WORDPRESS_DB_PASSWORD" --dbhost="$WORDPRESS_DB_HOST" --dbprefix="$(random_name)_" --skip-check --force --allow-root
    sleep 30
    "$WP_CLI" core install --url="$site_url" --title="Buckbeak" --admin_user="$admin_user" --admin_password="$admin_password" --admin_email="savalaelliott@gmail.com" --skip-email --allow-root
    sleep 30
    "$WP_CLI" plugin install woocommerce tourfic travelfic-toolkit --activate --allow-root
    sleep 30
    "$WP_CLI" theme install travelfic --activate --allow-root
    
    # Log the site information
    log_site_info "$site_path" "$admin_user" "$admin_password" "$site_url"
    
    echo "Site created successfully. Details have been logged to $LOG_FILE"
else
    echo "Error: WP-CLI not found. Please ensure it's installed and in your PATH"
    exit 1
fi