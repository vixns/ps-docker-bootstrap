#!/bin/sh

if [ ! -e  .env ]
then
	echo "Please create a .env file from env.dist"
	exit 1
fi

. ./.env

if [ -e app ]
then
	echo "Prestashop already installed, remove the app folder if you whant to reinstall from scratch."
	exit 1
fi

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
cp -a config/prestashop/parameters.php app/app/config/
docker-compose up -d --force-recreate app
docker-compose exec app composer require "symfony/polyfill-php80:<=1.18" "sentry/sentry-symfony"
sed -i -e "s/FOSJsRoutingBundle(),/FOSJsRoutingBundle(),\n            new Sentry\\\SentryBundle\\\SentryBundle(),/" app/app/AppKernel.php
echo "Please continue setup by visiting http://localhost:${HTTP_PORT}/install/ . When installed run ./post-install.sh"
