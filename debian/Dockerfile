FROM php:fpm

MAINTAINER Victor Rezende dos Santos

ADD https://download.videolan.org/pub/debian/videolan-apt.asc /tmp/videolan-apt.asc

RUN	apt-key add /tmp/videolan-apt.asc && rm /tmp/videolan-apt.asc \
 && echo 'deb http://http.debian.net/debian/ jessie main contrib non-free' > /etc/apt/sources.list \
 && echo 'deb http://http.debian.net/debian/ jessie-updates main contrib non-free' >> /etc/apt/sources.list \
 && echo 'deb http://security.debian.org/ jessie/updates main contrib non-free' >> /etc/apt/sources.list \
 && echo 'deb http://download.videolan.org/pub/debian/stable/ /' > /etc/apt/sources.list.d/videolan.list \
 && echo 'deb-src http://download.videolan.org/pub/debian/stable/ /' >> /etc/apt/sources.list.d/videolan.list \
 && apt-get update \
 && apt-get -y upgrade \
 && DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends -y install wget rsync inotify-tools git cron bzip2 lame libvorbis-dev vorbis-tools flac libmp3lame-dev libavcodec-extra* libtheora-dev libfaac-dev libvpx-dev libav-tools libfreetype6-dev libicu-dev libjpeg-dev libpng12-dev libldap2-dev 
 
WORKDIR /usr/src/
 
RUN debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)" \
 && docker-php-ext-configure ldap --with-libdir="lib/$debMultiarch" \
 && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
 && docker-php-ext-install gd ldap mysqli pdo_mysql \
 && php -r "readfile('https://getcomposer.org/installer');" | php \
 && mv composer.phar /usr/local/bin/composer \
 && echo "upload_max_filesize = 25M;" >> /usr/local/etc/php/conf.d/uploads.ini
 
 
ADD https://github.com/ampache/ampache/archive/master.tar.gz /usr/src/ampache-master.tar.gz
#ADD ampache.cfg.php.dist /var/temp/ampache.cfg.php.dist
 
RUN mkdir /usr/src/ampache && ln -s /usr/src/ampache /var/www/ampache \
 && tar -C /var/www/ampache -xf /usr/src/ampache-master.tar.gz ampache-master --strip=1 \
 && cd /var/www/ampache && composer install --prefer-source --no-interaction \
 && chown -R www-data /usr/src/ampache \
 && rm /var/www/ampache /usr/src/ampache-master.tar.gz

VOLUME ["/media"]
VOLUME ["/var/www/ampache/config"]
#RUN mkdir /var/www/ampache

EXPOSE 9000 
 
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod 555 /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
#CMD [ "php-fpm" ]
