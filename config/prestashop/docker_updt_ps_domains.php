<?php
/**
 * 2007-2016 PrestaShop
 *
 * NOTICE OF LICENSE
 *
 * This source file is subject to the Academic Free License (AFL 3.0)
 * that is bundled with this package in the file LICENSE.txt.
 * It is also available through the world-wide-web at this URL:
 * http://opensource.org/licenses/afl-3.0.php
 * If you did not receive a copy of the license and are unable to
 * obtain it through the world-wide-web, please send an email
 * to license@prestashop.com so we can send you a copy immediately.
 *
 * DISCLAIMER
 *
 * Do not edit or add to this file if you wish to upgrade PrestaShop to newer
 * versions in the future. If you wish to customize PrestaShop for your
 * needs please refer to http://www.prestashop.com for more information.
 *
 *  @author    PrestaShop SA <contact@prestashop.com>
 *  @copyright 2007-2016 PrestaShop SA
 *  @version  Release: $Revision: 14390 $
 *  @license   http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
 *  International Registered Trademark & Property of PrestaShop SA
 */

// Workaround for redirection on init
$_POST['id_shop'] = 1;

require_once 'config/config.inc.php';

if (!defined('_PS_VERSION_'))
	exit;

// First, we get the URL used to reach this page.
$domain = Tools::getHttpHost();
$old_domain = Configuration::get('PS_SHOP_DOMAIN');

if (version_compare(_PS_VERSION_, '1.5', '>=') && $domain != $old_domain && !Shop::isFeatureActive())
{
	$url = ShopUrl::getShopUrls(Configuration::get('PS_SHOP_DEFAULT'))->where('main', '=', 1)->getFirst();
	if ($url)
	{
		$url->domain = $domain;
		$url->domain_ssl = $domain;
		$url->save();

		// Then, we update the configuration table
		Configuration::updateValue('PS_SHOP_DOMAIN', $domain);
		Configuration::updateValue('PS_SHOP_DOMAIN_SSL', $domain);
	}
}

Configuration::updateValue('PS_SSL_ENABLED', 1);
Configuration::updateValue('PS_SSL_ENABLED_EVERYWHERE', 1);

Configuration::updateValue('PS_MAIL_METHOD', 2);
Configuration::updateValue('PS_MAIL_SERVER', getenv("SMTP_HOST"));
Configuration::updateValue('PS_MAIL_SMTP_PORT', getenv("SMTP_PORT"));
Configuration::updateValue('PS_MAIL_USER', getenv("SMTP_USER"));
Configuration::updateValue('PS_MAIL_PASSWD', getenv("SMTP_PASS"));

//unlink(__FILE__);
Tools::redirect("index.php");
die();
