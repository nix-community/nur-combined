<?php

declare(strict_types=1);

$env = static fn (string $name, string $default): string => getenv($name) ?: $default;
$join = static fn (string $base, string $path): string => rtrim($base, '/') . '/' . $path;

$dataDir = $env('SHLINK_DATA_DIR', getenv('STATE_DIRECTORY') ?: 'data');
$cacheDir = $env('SHLINK_CACHE_DIR', getenv('CACHE_DIRECTORY') ?: $join($dataDir, 'cache'));
$runtimeDir = $env('SHLINK_RUNTIME_DIR', getenv('RUNTIME_DIRECTORY') ?: $dataDir);

$geoliteDbPath = $env('SHLINK_GEOLITE_DB_PATH', $join($dataDir, 'GeoLite2-City.mmdb'));

$proxiesDir = $join($cacheDir, 'proxies');

$config = [
    'dependencies' => [
        'lazy_services' => [
            'proxies_target_dir' => $proxiesDir,
        ],
    ],

    'cache' => [
        'valinor_cache_dir' => $join($cacheDir, 'valinor'),
    ],

    'entity_manager' => [
        'orm' => [
            'proxies_dir' => $proxiesDir,
        ],
    ],

    'locks' => [
        'locks_dir' => $join($runtimeDir, 'locks'),
    ],

    'geolite2' => [
        'db_location' => $geoliteDbPath,
        'temp_dir' => $join($cacheDir, 'temp-geolite'),
    ],
];

if (strtolower(getenv('DB_DRIVER') ?: 'sqlite') === 'sqlite') {
    $config['entity_manager']['connection'] = [
        'driver' => 'pdo_sqlite',
        'path' => $join($dataDir, 'database.sqlite'),
    ];
}

return $config;
