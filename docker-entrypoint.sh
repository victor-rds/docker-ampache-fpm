#!/bin/bash
set -e
#if [[ ! -f /var/www/config/ampache.cfg.php ]]; then
#    mv /var/temp/ampache.cfg.php.dist /var/www/config/ampache.cfg.php.dist
#fi

if [[ ! -f /var/www/ampache/bin/catalog_update.inc ]]; then
	rsync -rlDog --chown www-data:root --exclude /config/ --exclude /themes/ /usr/src/ampache/ /var/www/ampache/
fi

if [[ ! -f /var/www/config/ampache.cfg.php ]]; then
	rsync -rlDog --chown www-data:root /usr/src/ampache/config/ /var/www/ampache/config/
	rsync -rlDog --chown www-data:root /usr/src/ampache/themes/ /var/www/ampache/themes/
fi

# Start cron in the background
echo '30 7    * * *   www-data php /var/www/ampache/bin/catalog_update.inc' >> /etc/crontab

cron

# Start a process to watch for changes in the library with inotify
(
while true; do
    inotifywatch /media
    php /var/www/ampache/bin/catalog_update.inc -a
    sleep 30
done
) &

echo "Entrypoint end!"

exec php-fpm
