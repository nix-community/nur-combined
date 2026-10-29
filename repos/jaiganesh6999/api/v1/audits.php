<?php
declare(strict_types=1);

/**
 * Direct endpoint entrypoint for /api/v1/audits.php
 */
$_SERVER['REQUEST_METHOD'] = 'GET';
$_SERVER['REQUEST_URI'] = '/api/v1/audits';
require_once __DIR__ . '/index.php';
