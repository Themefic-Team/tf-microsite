    #!/bin/bash

    # Tasks
    # 1. Generate a random name
    # 2. Create a directory and WordPress Installation
    # 3. Add Database and DB Prefix to this script
    # 4. Install WP CLI and Activate The Plugin
    # 5. Create a crontab for the wp system

    # Variables
    MainDir="/var/www/html"

    source .env

    random_name() {
        length=${1:-8}
        characters="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        random_string=""

        for i in $(seq 1 $length); do
            random_index=$((RANDOM % ${#characters}))
            random_string+="${characters:$random_index:1}"
        done

        echo $random_string
    }

    create_directory() {
        dir_name=$1
        mkdir -p "$MainDir/$dir_name"
        echo "Directory $MainDir/$dir_name created."
    }

    if [ $(which wp &> /dev/null; echo $?) -eq 0 ]; then
        wp core download --path="$MainDir/$name" --allow-root
        sleep 30
        wp config create --dbname="$WORDPRESS_DB_NAME" --dbuser="$WORDPRESS_DB_USER" --dbpass="$WORDPRESS_DB_PASSWORD" --dbhost=172.31.17.176:3306 --dbprefix=helloWorld_ --skip-check --force
        sleep 30
        wp core install --url="http://$name.local" --title="$name" --admin_user="$WORDPRESS_ADMIN_USER" --admin_password="$WORDPRESS_ADMIN_PASSWORD" --admin_email="$WORDPRESS_ADMIN_EMAIL" --skip-email
        sleep 30
        wp plugin install woocommerce tourfic --activate

    else
        echo "wp command is not available"
    fi



    # wp_cli_install() {
        
    # }

    name=$(random_name)
    echo "Random name generated: $name"