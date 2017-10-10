FROM php:fpm

MAINTAINER Victor Rezende dos Santos

ADD https://download.videolan.org/pub/debian/videolan-apt.asc /tmp/videolan-apt.asc
	
RUN	apt-key add /tmp/videolan-apt.asc && rm /tmp/videolan-apt.asc && \
	echo 'deb http://http.debian.net/debian/ jessie main contrib non-free' > /etc/apt/sources.list && \
	echo 'deb http://http.debian.net/debian/ jessie-updates main contrib non-free' >> /etc/apt/sources.list && \
	echo 'deb http://security.debian.org/ jessie/updates main contrib non-free' >> /etc/apt/sources.list && \
	echo 'deb http://http.debian.net/debian jessie-backports main' > /etc/apt/sources.list.d/backports.list && \
	echo 'deb http://download.videolan.org/pub/debian/stable/ /' > /etc/apt/sources.list.d/videolan.list \
	echo 'deb-src http://download.videolan.org/pub/debian/stable/ /' >> /etc/apt/sources.list.d/videolan.list && \
	apt-get update && \
	apt-get -y upgrade && \
	DEBIAN_FRONTEND=noninteractive apt-get -y install wget inotify-tools git cron bzip2 lame libvorbis-dev vorbis-tools flac libmp3lame-dev libavcodec-extra* libtheora-dev libfaac-dev libvpx-dev libav-tools

RUN docker ps -a
docker-php-ext-install mysqli pdo_mysql

RUN php -r "readfile('https://getcomposer.org/installer');" | php && \
	mv composer.phar /usr/local/bin/composer	
#RUN DEBIAN_FRONTEND=noninteractive apt-get -y install lame libvorbis-dev vorbis-tools flac libmp3lame-dev libavcodec-extra* libfaac-dev libtheora-dev libvpx-dev libav-tools git

# For local testing / faster builds # COPY master.tar.gz /opt/master.tar.gz 
ADD https://github.com/ampache/ampache/archive/master.tar.gz /opt/ampache-master.tar.gz
#ADD ampache.cfg.php.dist /var/temp/ampache.cfg.php.dist

RUN rm -rf /var/www/* && \
	tar -C /var/www -xf /opt/ampache-master.tar.gz ampache-master --strip=1 && \
	cd /var/www && composer install --prefer-source --no-interaction && \
	chown -R www-data /var/www

VOLUME ["/media"]
VOLUME ["/var/www/config"]
VOLUME ["/var/www/themes"]
EXPOSE 9000 
 
COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
