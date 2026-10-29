<?php
declare(strict_types=1);

/**
 * Direct endpoint entrypoint for /api/v1/audit.php
 */
$_SERVER['REQUEST_METHOD'] = $_SERVER['REQUEST_METHOD'] ?? 'POST';
$_SERVER['REQUEST_URI'] = '/api/v1/audit';
require_once __DIR__ . '/index.php';
