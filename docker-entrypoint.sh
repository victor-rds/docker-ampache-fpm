#!/bin/bash
set -e
#if [[ ! -f /var/www/config/ampache.cfg.php ]]; then
#    mv /var/temp/ampache.cfg.php.dist /var/www/config/ampache.cfg.php.dist
#fi

# Start cron in the background
echo '30 7    * * *   www-data php /var/www/bin/catalog_update.inc' >> /etc/crontab

cron

# Start a process to watch for changes in the library with inotify
(
while true; do
    inotifywatch /media
    php /var/www/bin/catalog_update.inc -a
    sleep 30
done
) &

exec php-fpm
