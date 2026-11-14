<?php
// Pod-native app paths (replaces the NixOS /nix/store paths that came with
// the seeded config). Loaded after config.php; kept minimal on purpose —
// everything else is managed via `occ config:system:set`.
$CONFIG = [
  'apps_paths' => [
    [
      'path' => '/var/www/html/apps',
      'url' => '/apps',
      'writable' => false,
    ],
    [
      'path' => '/var/www/html/custom_apps',
      'url' => '/custom_apps',
      'writable' => true,
    ],
  ],
  'appstoreenabled' => true,
];
