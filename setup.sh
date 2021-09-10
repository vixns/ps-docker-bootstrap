#!/bin/bash

PS_VERSION=1.7.7.7
PS_VERSION_BRANCH=1.7.7.x

if [ -e app ]
then
	echo "Prestashop already installed, remove the app folder if you whant to reinstall from scratch."
	exit 1
fi

# is docker installed
command -v docker > /dev/null
[ $? -eq 0 ] || error "Please install docker first, see https://www.docker.com/products/docker-desktop"

# is docker-compose installed
command -v docker-compose > /dev/null
[ $? -eq 0 ] || error "Please install docker-compose, see https://docs.docker.com/compose/install/"

# is curl or wget installed
command -v curl > /dev/null || command -v wget > /dev/null
[ $? -eq 0 ] || error "Please install curl or wget."

# is nc installed
command -v nc > /dev/null
[ $? -eq 0 ] || error "Please install netcat."

# Cleanup git repository

if [ ! -e .develop ]
then
    echo "cleanup.sh" >> .gitignore
    echo "setup.sh" >> .gitignore
else
    cat > cleanup.sh << EOF
#!/bin/sh
[ -e docker-compose.yml ] && docker-compose down -v
rm -rf .mc s3 app docker-compose.yml docker-compose-dproxy.yml .vixns-ci.yml Jenkinsfile
EOF
  chmod +x cleanup.sh
fi

rm -rf .git
git init -q
git checkout -q -b develop
git add .
git commit -m "Initial Import" 2>&1 >/dev/null
cat > .git/hooks/pre-commit << EOF
#!/bin/sh
command -v curl > /dev/null
if [ \$? -eq 0 ]
then
curlf() {
  OUTPUT_FILE=\$(mktemp)
  HTTP_CODE=\$(curl --silent --output \$OUTPUT_FILE --write-out "%{http_code}" "\$@")
  if [ "\${HTTP_CODE}" != "200" ] ; then
    >&2 cat \$OUTPUT_FILE
    rm \$OUTPUT_FILE
    exit 22
  fi
  cat \$OUTPUT_FILE
  rm \$OUTPUT_FILE
}
curlf https://deploy.vixns.net/verify --data-binary @.vixns-ci.yml
else
wget -q -o - https://deploy.vixns.net/verify --post-file .vixns-ci.yml
fi

EOF
chmod +x .git/hooks/pre-commit



# Let's Roll

case $PS_LANG in
    "fr")
		PS_LANG=fr
    ;;
    "en")
		PS_LANG=en
    ;;
    *)
        PS3='Choose your language: '
        l=("Français" "English")
        select fav in "${l[@]}"; do
            case $fav in
                "English")
                    PS_LANG=en
                break
                ;;
                "Français")
                    PS_LANG=fr
                break
                    ;;
                *) echo "invalid option $REPLY, use 1 or 2";;
            esac
        done
    ;;
esac

case $PS_LANG in
    "fr")
        while [ $(echo -n "$DOCKER_REGISTRY" | wc -c) -lt 2 ]
        do
            read -p "Nom d'hote du registry docker: (docker.vixns.net par defaut) " DOCKER_REGISTRY
            DOCKER_REGISTRY="${DOCKER_REGISTRY:=docker.vixns.net}"
        done
        while [ $(echo -n "$MYSQL_MARATHON_PATH" | wc -c) -lt 2 ]
        do
            read -p "Chemin du cluster mysql (exemple: mysql-master-common-test.marathon.vx): " MYSQL_MARATHON_PATH
        done
        while [ $(echo -n "$PROD_FQDN" | wc -c) -lt 2 ]
        do
            read -p "Nom d'hote de production: " PROD_FQDN
        done
        while [ $(echo -n "$PREPROD_FQDN" | wc -c) -lt 2 ]
        do
            read -p "Nom d'hote de pre-production: " PREPROD_FQDN
        done
        while [ $(echo -n "$PREPROD_USER" | wc -c) -lt 2 ]
        do
            read -p "Nom d'utilisateur http basic de pre-production: " PREPROD_USER
        done
        while [ $(echo -n "$PREPROD_PASSWD" | wc -c) -lt 2 ]
        do
            read -p "Mot de passe http basic de pre-production : " PREPROD_PASSWD
        done
        while [ $(echo -n "$ADMIN_FOLDER" | wc -c) -lt 2 ]
        do
            read -p "Nom du dossier d'administration (ne pas utiliser \"admin\"): " ADMIN_FOLDER
        done
        while [ $(echo -n "$ADMIN_EMAIL" | wc -c) -lt 5 ]
        do
            read -p "Adresse email de l'administrateur: " ADMIN_EMAIL
        done
        while [ $(echo -n "$ADMIN_FIRSTNAME" | wc -c) -lt 2 ]
        do
            read -p "Prénom de l'administrateur: " ADMIN_FIRSTNAME
        done
        while [ $(echo -n "$ADMIN_LASTNAME" | wc -c) -lt 2 ]
        do
            read -p "Nom de l'administrateur: " ADMIN_LASTNAME
        done
        while [ $(echo -n "$ADMIN_PASSWORD" | wc -c) -lt 8 ]
        do
            read -p "Mot de passe de l'administrateur: " ADMIN_PASSWORD
        done
        while [ $(echo -n "$GITHUB_TOKEN" | wc -c) -lt 2 ]
        do
            read -p "Jeton github.com pour composer à générer sur https://github.com/settings/tokens/new?scopes=repo&description=Composer+ps : " GITHUB_TOKEN
        done
        ;;
    *)
        while [ $(echo -n "$DOCKER_REGISTRY" | wc -c) -lt 2 ]
        do
            read -p "Docker registry FQDN: (default: docker.vixns.net) " DOCKER_REGISTRY
            DOCKER_REGISTRY="${DOCKER_REGISTRY:=docker.vixns.net}"
        done
        while [ $(echo -n "$MYSQL_MARATHON_PATH" | wc -c) -lt 2 ]
        do
            read -p "Mysql cluster path (eg: mysql-master-common-test.marathon.vx): " MYSQL_MARATHON_PATH
        done
        while [ $(echo -n "$PROD_FQDN" | wc -c) -lt 2 ]
        do
            read -p "Production FQDN: " PROD_FQDN
        done
        while [ $(echo -n "$PREPROD_FQDN" | wc -c) -lt 2 ]
        do
            read -p "Staging FQDN: " PREPROD_FQDN
        done
        while [ $(echo -n "$PREPROD_USER" | wc -c) -lt 2 ]
        do
            read -p "Staging http basic username: " PREPROD_USER
        done
        while [ $(echo -n "$PREPROD_PASSWD" | wc -c) -lt 2 ]
        do
            read -p "Staging http basic password : " PREPROD_PASSWD
        done
        while [ $(echo -n "$ADMIN_FOLDER" | wc -c) -lt 2 ]
        do
            read -p "Admin folder name (do not use \"admin\"): " ADMIN_FOLDER
        done
        while [ $(echo -n "$ADMIN_EMAIL" | wc -c) -lt 5 ]
        do
            read -p "Administrator email address: " ADMIN_EMAIL
        done
        while [ $(echo -n "$ADMIN_FIRSTNAME" | wc -c) -lt 2 ]
        do
            read -p "Administrator firstname: " ADMIN_FIRSTNAME
        done
        while [ $(echo -n "$ADMIN_LASTNAME" | wc -c) -lt 2 ]
        do
            read -p "Administrator lastname: " ADMIN_LASTNAME
        done
        while [ $(echo -n "$ADMIN_PASSWORD" | wc -c) -lt 8 ]
        do
            read -p "Administrator password: " ADMIN_PASSWORD
        done
        while [ $(echo -n "$GITHUB_TOKEN" | wc -c) -lt 2 ]
        do
            read -p "github.com composer token from https://github.com/settings/tokens/new?scopes=repo&description=Composer+ps : " GITHUB_TOKEN
        done
        ;;
esac


HTTP_PORT=8080
HTTPS_PORT=1443
PMA_PORT=8008
MH_PORT=8025
MINIO_PORT=9000
MINIO_CONSOLE_PORT=9001
DB_PORT=3306

while true
do
    nc -tz -w 1 localhost ${HTTP_PORT} 2> /dev/null
    [ "$?" -eq "1" ] && break
    HTTP_PORT=$(expr ${HTTP_PORT} + 1)
done
while true
do
    nc -tz -w 1 localhost ${HTTPS_PORT} 2> /dev/null
    [ "$?" -eq "1" ] && break
    HTTPS_PORT=$(expr ${HTTPS_PORT} + 1)
done
while true
do
    nc -tz -w 1 localhost ${PMA_PORT} 2> /dev/null
    [ "$?" -eq "1" ] && break
    PMA_PORT=$(expr ${PMA_PORT} + 1)
done
while true
do
    nc -tz -w 1 localhost ${MH_PORT} 2> /dev/null
    [ "$?" -eq "1" ] && break
    MH_PORT=$(expr ${MH_PORT} + 1)
done
while true
do
    nc -tz -w 1 localhost ${MINIO_PORT} 2> /dev/null
    [ "$?" -eq "1" ] && break
    MINIO_PORT=$(expr ${MINIO_PORT} + 2)
done
while true
do
    nc -tz -w 1 localhost ${MINIO_CONSOLE_PORT} 2> /dev/null
    [ "$?" -eq "1" ] && break
    MINIO_CONSOLE_PORT=$(expr ${MINIO_CONSOLE_PORT} + 2)
done
while true
do
    nc -tz -w 1 localhost ${DB_PORT} 2> /dev/null
    [ "$?" -eq "1" ] && break
    DB_PORT=$(expr ${DB_PORT} + 1)
done

case $PS_LANG in
    "fr") echo "Téléchargement de Prestashop";;
    *) echo "Downloading Prestashop";;
esac

mkdir -p app/app/cache
cd app
curl -s -L -O https://download.prestashop.com/download/releases/prestashop_${PS_VERSION}.zip
curl -s -L -O https://raw.githubusercontent.com/PrestaShop/PrestaShop/${PS_VERSION_BRANCH}/composer.json
sed -i -e "/^.*clearCache.*$/d" composer.json
curl -s -L -O https://raw.githubusercontent.com/PrestaShop/PrestaShop/${PS_VERSION_BRANCH}/composer.lock
unzip -o -q prestashop_${PS_VERSION}.zip
rm prestashop_${PS_VERSION}.zip
unzip -o -q prestashop.zip
rm Install_PrestaShop.html prestashop.zip
cd ..

# Creating .env file
case $PS_LANG in
    "fr") echo "Génération du fichier .env";;
    *) echo "Create .env file";;
esac

echo "UID=$(id -u)" > .env
echo "COMPOSE_FILE=docker-compose.yml" >> .env
echo "_PS_MODE_DEV_=true" >> .env
echo "DB_HOST=db" >> .env
echo "DB_PORT=${DB_PORT}" >> .env
echo "DB_NAME=prestashop" >> .env
echo "DB_USER=psuser" >> .env
echo "DB_PASSWORD=pspass" >> .env
echo "PMA_PORT=${PMA_PORT}" >> .env
echo "PS_URL=httpa://localhost:${HTTPS_PORT}" >> .env
echo "SMTP_HOST=mh" >> .env
echo "SMTP_PORT=1025" >> .env
echo "SMTP_AUTH=false" >> .env
echo "SMTP_USER=''" >> .env
echo "SMTP_PASS=''" >> .env
echo "MH_PORT=${MH_PORT}" >> .env
echo "MINIO_PORT=${MINIO_PORT}" >> .env
echo "MINIO_CONSOLE_PORT=${MINIO_CONSOLE_PORT}" >> .env
echo "S3_UPLOADS_URL=http://localhost:${MINIO_PORT}" >> .env
echo "HTTP_PORT=${HTTP_PORT}" >> .env
echo "SENTRY_DSN=" >> .env
echo "VERSION=dev" >> .env
echo "S3_ENDPOINT=http://minio:9000" >> .env
echo "S3_UPLOADS_KEY=minioadmin" >> .env
echo "S3_UPLOADS_SECRET=minioadmin" >> .env
echo "S3_UPLOADS_BUCKET=prestashop" >> .env
echo "S3_UPLOADS_REGION=eu-west-1" >> .env
echo "ADMIN_FOLDER=${ADMIN_FOLDER}" >> .env

# create compose file
echo "Create compose file"
cat > docker-compose.yml << EOF
version: '3'
services:
  db:
    image: mariadb
    networks:
      - back
    ports:
      - "\${DB_PORT:-3306}:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=notaseriouspass
      - MYSQL_DATABASE=\${DB_NAME}
      - MYSQL_USER=\${DB_USER}
      - MYSQL_PASSWORD=\${DB_PASSWORD}
  pma:
    image: phpmyadmin
    networks:
      - back
      - proxy
    ports:
      - "\${PMA_PORT:-8008}:80"
    environment:
      - PMA_HOST=db
      - PMA_USER=root
      - PMA_PASSWORD=notaseriouspass
      - PHP_UPLOAD_MAX_FILESIZE=1G
      - PHP_MAX_INPUT_VARS=1G
  mh:
    image: mailhog/mailhog
    networks:
      - back
      - proxy
    ports:
      - "\${MH_PORT:-8025}:8025"
  app:
    depends_on:
      - db
      - mh
    build:
      context: .
      args:
        UID: \${UID}
    networks:
      - back
      - proxy
    ports:
      - "8080"
    env_file: ./.env
    volumes:
      - ./app:/data/htdocs:cached
      - /data/htdocs/app/cache
  proxy:
    image: haproxy
    depends_on:
      - app
    networks:
      - proxy
    volumes:
      - ./config/haproxy:/usr/local/etc/haproxy
    ports:
      - "127.0.0.1:${HTTP_PORT}:80"
      - "127.0.0.1:${HTTPS_PORT}:443"
volumes:
  mysql-data:
    driver: local

networks:
  back:
  proxy:
EOF

# create dproxy compatible compose file
echo "Create dproxy compatible compose file"
cat > docker-compose-dproxy.yml << EOF
version: '3'
services:
  app:
    depends_on:
      - minio
    build:
      context: .
      args:
        UID: \${UID}
    networks:
      - default
      - proxy
      - smtp
      - mysql
    ports:
      - "8080"
    env_file: ./.env
    volumes:
      - ./app:/data/htdocs:cached
      - /data/htdocs/app/cache
    labels:
      - "traefik.frontend.rule=Host:\${HOSTNAME}.\${DOMAIN}"

networks:
  default:
  mysql:
    external:
      name: mysql
  proxy:
    external:
      name: proxy
  smtp:
    external:
      name: smtp

EOF

echo "Create Vixns Continuous Deployment configuration"
cat > Jenkinsfile << EOF
properties([gitLabConnection('Gitlab')])
node {
  checkout scm
  gitlabCommitStatus {
    vixnsCi('.vixns-ci.yml');
  }
}
EOF


cat > .vixns-ci.yml << EOF
docker:
  builds:

deploy:
  - name: app
    cpu: 0.1
    mem: 512
    docker:
      build: app
    ports:
      - name: http
        number: 8080
        check:
          type: http
          path: /ping.php
        routing:
          develop:
            domains:
            - preprod.myapp.com
            auth:
              user: private
              password: app
          master:
            domains:
            - www.myapp.com


version: 1

global:
  project_name: $(pwd | awk -F'/' '{print $NF}')

docker:
  builds:
  - name: app
    registry: ${DOCKER_REGISTRY}
    env:
      HOME: /tmp
      MYSQL_HOST: localhost
      SYMFONY_ENV: prod
      MYSQL_DATABASE:
        secret:
          name: db
          key: name
      MYSQL_USER:
        secret:
          name: db
          key: user
      MYSQL_PASSWORD:
        secret:
          name: db
          key: password
      SMTP_HOST:
        secret:
          name: smtp
          key: host
      SENTRY_DSN:
        secret:
          name: sentry
          key: dsn
      SENTRY_RELEASE: "%shortcommit%"
      SENTRY_NAME: fed
      PS_SECRET:
        secret:
          name: ps
          key: secret
      PS_COOKIE_KEY:
        secret:
          name: ps
          key: cookiekey
      PS_COOKIE_IV:
        secret:
          name: ps
          key: cookieiv
      PS_NEW_COOKIE_KEY:
        secret:
          name: ps
          key: newcookiekey
      MYSQL1:
        secret:
          name: mysql
          key: node1
      MYSQL2:
        secret:
          name: mysql
          key: node2
      MYSQL3:
        secret:
          name: mysql
          key: node3
      PROXYSQL_ADMIN_PASSWORD:
        secret:
          name: proxysql
          key: admin_password
      PROXYSQL_MONITOR_PASSWORD:
        secret:
          name: proxysql
          key: monitor_password
      MYSQL1: node1-${MYSQL_MARATHON_PATH}
      MYSQL2: node2-${MYSQL_MARATHON_PATH}
      MYSQL3: node3-${MYSQL_MARATHON_PATH}
    volumes:
      - path: /data/img
        name: img
        size: 10G
        type: nas
      - path: /data/htdocs/upload
        name: upload
        size: 10G
        type: nas

deploy:
  - name: app
    user: www-data
    cpu: 0.1
    mem: 512
    docker:
      build: app
    ports:
      - name: http
        number: 8080
        check:
          type: http
          path: /ping.php
        routing:
          develop:
            domains:
            - "${PREPROD_FQDN}"
            auth:
              user: "${PREPROD_USER}"
              password: "${PREPROD_PASSWD}"
          master:
            domains:
            - "${PROD_FQDN}"
EOF

docker-compose up -d --force-recreate app

echo "Install sentry package"
docker-compose exec -e COMPOSER_HOME=/tmp -e COMPOSER_AUTH="{\"github-oauth\": {\"github.com\": \"${GITHUB_TOKEN}\"}}" app composer require "symfony/polyfill-php80:<=1.18" "sentry/sentry-symfony"
sed -i -e "s/FOSJsRoutingBundle(),/FOSJsRoutingBundle(),\n            new Sentry\\\SentryBundle\\\SentryBundle(),/" app/app/AppKernel.php

echo "Run prestashop installer"

docker-compose exec app php install/index_cli.php \
	--language=${PS_LANG} \
	--ssl \
	--domain=localhost \
	--db_server=db \
	--db_name=prestashop \
	--db_user=psuser \
	--db_password=pspass \
	--timezone=Europe/paris \
	--email=${ADMIN_EMAIL} \
	--firstname=${ADMIN_FIRSTNAME} \
	--lastname=${ADMIN_LASTNAME} \
	--password=${ADMIN_PASSWORD}

echo "PS_SECRET=$(grep "'secret'" app/app/config/parameters.php | awk -F"'" '{print $4}')" >> .env
echo "PS_COOKIE_KEY=$(grep "'cookie_key'" app/app/config/parameters.php | awk -F"'" '{print $4}')" >> .env
echo "PS_COOKIE_IV=$(grep "'cookie_iv'" app/app/config/parameters.php | awk -F"'" '{print $4}')" >> .env
echo "PS_NEW_COOKIE_KEY=$(grep "'new_cookie_key'" app/app/config/parameters.php | awk -F"'" '{print $4}')" >> .env

rm -rf app/install
cp -a config/prestashop/parameters.php app/app/config/
cp -a config/prestashop/config_prod.yml app/app/config/
cp -a config/prestashop/docker_updt_ps_domains.php app/
cp -a config/prestashop/ping.php app/
mv app/admin app/${ADMIN_FOLDER}
docker-compose up -d --force-recreate
curl -k -s -o /dev/null https://localhost:${HTTPS_PORT}/docker_updt_ps_domains.php


echo "Commit base install"
git add .
git commit -m "Prestashop installed" 2>&1 >/dev/null

echo "============================================================="
echo
case $PS_LANG in
    "fr")
    echo "Installation de Prestashop terminée."
    ;;
    *)
    echo "Prestashop successfully installed."
    ;;
esac

echo
echo "Home : https://localhost:${HTTPS_PORT}"
echo "Admin: https://localhost:${HTTPS_PORT}/${ADMIN_FOLDER}"
echo "Utilisateur: $ADMIN_EMAIL"
echo "Mot de passe: $ADMIN_PASSWORD"
echo
echo "Mailhog: http://localhost:${MH_PORT}"
echo
echo "Mysql port: ${DB_PORT}"
echo "phpMyAdmin: http://localhost:${PMA_PORT}"
echo
echo "============================================================="

[ -e .develop ] || rm -f setup.sh
