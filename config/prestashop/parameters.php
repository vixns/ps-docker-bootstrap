<?php return array (
  'parameters' =>
  array (
    'database_host' => getenv('MYSQL_HOST'),
    'database_port' => getenv('MYSQL_PORT'),
    'database_name' => getenv('MYSQL_DATABASE'),
    'database_user' => getenv('MYSQL_USER'),
    'database_password' => getenv('MYSQL_PASSWORD'),
    'database_prefix' => 'ps_',
    'database_engine' => 'InnoDB',
    'sentry_dsn' => getenv('SENTRY_DSN'),
    'sentry_name' => getenv('SENTRY_NAME'),
    'sentry_release' => getenv('VERSION'),
    'mailer_transport' => 'smtp',
    'mailer_host' => getenv('SMTP_HOST'),
    'mailer_user' => NULL,
    'mailer_password' => NULL,
    'secret' => getenv('PS_SECRET'),
    'ps_caching' => 'CacheApc',
    'ps_cache_enable' => filter_var(getenv('CACHE_ENABLED'), FILTER_VALIDATE_BOOLEAN),
    'ps_creation_date' => '2017-04-07',
    'locale' => 'fr-FR',
    'use_debug_toolbar' => filter_var(getenv('DEBUG_TOOLBAR'), FILTER_VALIDATE_BOOLEAN),
    'cookie_key' => getenv('PS_COOKIE_KEY'),
    'cookie_iv' => getenv('PS_COOKIE_IV'),
    'new_cookie_key' => getenv('PS_NEW_COOKIE_KEY'),
  )
);
