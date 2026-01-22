FROM public.ecr.aws/docker/library/php:8.2-fpm-alpine

RUN docker-php-ext-install pdo pdo_mysql

COPY src/ /var/www/html/

EXPOSE 9000