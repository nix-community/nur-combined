<?php

declare(strict_types=1);

namespace SeoWebChecker\SeoAudit;

use RuntimeException;

/**
 * Cloud API Client for SEOWebChecker (https://seowebchecker.com/)
 */
class Client
{
    private ?string $apiKey;
    private string $baseUrl;
    private int $timeout;

    public function __construct(
        ?string $apiKey = null,
        string $baseUrl = 'https://seowebchecker.com/api/v1',
        int $timeout = 30
    ) {
        $this->apiKey = $apiKey;
        $this->baseUrl = rtrim($baseUrl, '/');
        $this->timeout = $timeout;
    }

    private function request(string $method, string $endpoint, ?array $data = null): array
    {
        $url = "{$this->baseUrl}/" . ltrim($endpoint, '/');
        $headers = [
            'Content-Type: application/json',
            'Accept: application/json',
            'User-Agent: SEOWebChecker-Php-SDK/1.0.0 (+https://seowebchecker.com/)',
        ];

        if ($this->apiKey) {
            $headers[] = "Authorization: Bearer {$this->apiKey}";
            $headers[] = "X-API-Key: {$this->apiKey}";
        }

        $opts = [
            'http' => [
                'method' => strtoupper($method),
                'header' => implode("\r\n", $headers),
                'timeout' => $this->timeout,
                'ignore_errors' => true,
            ]
        ];

        if ($data !== null) {
            $opts['http']['content'] = json_encode($data);
        }

        $response = @file_get_contents($url, false, stream_context_create($opts));

        if ($response === false) {
            throw new RuntimeException("Failed to connect to SEOWebChecker API at {$url}");
        }

        $decoded = json_decode($response, true);
        return is_array($decoded) ? $decoded : ['raw' => $response];
    }

    public function audit(string $url, array $options = []): array
    {
        return $this->request('POST', 'audit', array_merge(['url' => $url], $options));
    }

    public function getAudit(string $auditId): array
    {
        return $this->request('GET', "audit/{$auditId}");
    }

    public function getHistory(int $limit = 10): array
    {
        return $this->request('GET', "audits?limit={$limit}");
    }
}
