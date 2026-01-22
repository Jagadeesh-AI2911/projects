FROM public.ecr.aws/docker/library/nginx:alpine

RUN rm /etc/nginx/conf.d/default.conf

COPY docker/nginx/default.conf /etc/nginx/conf.d/

COPY src/ /var/www/html/