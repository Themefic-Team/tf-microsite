#!/bin/bash

    # Variables
    MainDir="/srv/www/wordpress"

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
        dir_name=$(random_name)
        mkdir -p "$MainDir/$dir_name"
        cd "$MainDir/$dir_name"
        echo "$MainDir/$dir_name"
    }

        create_directory

    if [ $(which wp &> /dev/null; echo $?) -eq 0 ]; then
        wp core download --allow-root
        sleep 30
        wp config create --dbname="$WORDPRESS_DB_NAME" --dbuser="$WORDPRESS_DB_USER" --dbpass="$WORDPRESS_DB_PASSWORD" --dbhost="$WORDPRESS_DB_HOST" --dbprefix="$(random_name)_" --skip-check --force --allow-root
        sleep 30
        wp core install --url="$WORDPRESS_URL/$(random_name)" --title="Buckbeak" --admin_user="$(random_name)" --admin_password="$(random_name)@9448" --admin_email="savalaelliott@gmail.com" --skip-email --allow-root
        sleep 30
        wp plugin install woocommerce tourfic --activate --allow-root

    else
        echo "wp command is not available"
    fi
root@srv824072:~/microsite#
root@srv824072:~/microsite# nano microsite.sh
root@srv824072:~/microsite#
root@srv824072:~/microsite# cat microsite.sh
    #!/bin/bash

    # Variables
    MainDir="/srv/www/wordpress"

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
        dir_name=$(random_name)
        mkdir -p "$MainDir/$dir_name"
        cd "$MainDir/$dir_name"
        echo "$MainDir/$dir_name"
    }

        create_directory

    if [ $(which wp &> /dev/null; echo $?) -eq 0 ]; then
        wp core download --allow-root
        sleep 30
        wp config create --dbname="$WORDPRESS_DB_NAME" --dbuser="$WORDPRESS_DB_USER" --dbpass="$WORDPRESS_DB_PASSWORD" --dbhost="$WORDPRESS_DB_HOST" --dbprefix="$(random_name)_" --skip-check --force --allow-root
        sleep 30
        wp core install --url="$WORDPRESS_URL/$(random_name)" --title="Buckbeak" --admin_user="$(random_name)" --admin_password="$(random_name)@9448" --admin_email="savalaelliott@gmail.com" --skip-email --allow-root
        sleep 30
        wp plugin install woocommerce tourfic travelfic-toolkit --activate --allow-root
        sleep 30
        wp theme install travelfic --activate --allow-root

    else
        echo "wp command is not available"
    fi