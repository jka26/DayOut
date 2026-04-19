FROM php:8.2-apache

RUN docker-php-ext-install pdo pdo_mysql && a2enmod rewrite headers

COPY . /var/www/html/

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN echo '<Directory /var/www/html>\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' >> /etc/apache2/apache2.conf

EXPOSE 80
