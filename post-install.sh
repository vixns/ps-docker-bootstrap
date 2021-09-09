#!/bin/sh

if [ ! -e  .env ]
then
	echo "missing .env file"
	exit 1
fi

. ./.env

rm -rf app/install
cp -a config/prestashop/parameters.php app/app/config/
cp -a config/prestashop/config_prod.yml app/app/config/
cp -a config/prestashop/docker_updt_ps_domains.php app/
cp -a config/prestashop/ping.php app/
mv app/admin app/${ADMIN_FOLDER}
docker-compose up -d --force-recreate app
curl -k -s -o /dev/null https://localhost:${HTTPS_PORT}/docker_updt_ps_domains.php
echo "post installation finished: https://localhost:${HTTPS_PORT}"