FROM php:7.3-apache
LABEL maintainer "prateeks@utexas.edu"
#Install git
RUN apt-get update \
    && apt-get install -y git iputils-ping
RUN docker-php-ext-install pdo pdo_mysql mysqli
RUN a2enmod rewrite
#Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=. --filename=composer
RUN mv composer /usr/local/bin/

COPY php.ini /usr/local/etc/php/php.ini
COPY dvwa /var/www/html
COPY config.inc.php /var/www/html/config/

RUN chown www-data:www-data -R /var/www/html 

EXPOSE 80

COPY main.sh /
ENTRYPOINT ["/main.sh"]
