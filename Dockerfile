FROM vixns/php-nginx:7.4-debian-nonroot
ARG UID
ENV MYSQL_HOST=localhost MYSQL_PORT=3306 SMTP_HOST=mailhog VERSION=dev

USER root

RUN apt-get update && \
  apt-get install --no-install-recommends -y \
  default-libmysqlclient-dev default-mysql-client nmap less git libzip-dev unzip \
  locales git libicu-dev libmcrypt-dev && \
  echo  "fr_FR.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && \
  rm -rf /var/lib/apt/lists/* && \
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
  usermod -u ${UID:-33} www-data && \
  chown -R www-data:www-data /var/log/nginx /var/lib/nginx /etc/service /run && \
  docker-php-ext-install pdo_mysql zip mysqli intl && \
  pecl install mcrypt && \
  echo "extension=mcrypt.so" >> "/usr/local/etc/php/conf.d/mcrypt.ini" && \
  pecl install apcu && \
  echo "extension=apcu.so" >> "/usr/local/etc/php/conf.d/apcu.ini" && \
  echo "mysql.default_socket=/tmp/mysqld.sock" > "/usr/local/etc/php/conf.d/mysql.ini" && \
  echo "mysqli.default_socket=/tmp/mysqld.sock" > "/usr/local/etc/php/conf.d/mysqli.ini" && \
  echo "pdo_mysql.default_socket=/tmp/mysqld.sock" > "/usr/local/etc/php/conf.d/pdo_mysql.ini"

USER www-data

COPY --chown=www-data:www-data app /data/htdocs
WORKDIR "/data/htdocs"

COPY config/nginx/nginx.conf /etc/service/nginx/nginx.conf.tpl
COPY config/nginx/rewrite.map /etc/nginx/rewrite.map
COPY config/php/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY config/proxysql/proxysql-run.sh /etc/service/proxysql/run
COPY config/proxysql/proxysql.cnf.tpl /etc/proxysql/proxysql.cnf.tpl

COPY --chown=www-data:www-data config/nginx/run /etc/service/nginx/run

RUN mkdir /data/htdocs/logs

