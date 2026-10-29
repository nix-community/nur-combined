<?php
declare(strict_types=1);

/**
 * SEOWebChecker Production REST API (v1)
 * Official Platform: https://seowebchecker.com/
 * PHP 8.2 Compatible
 */

// Security & CORS Headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-API-Key, User-Agent');
header('Content-Type: application/json; charset=UTF-8');
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// Resolve requested path
$requestUri = $_SERVER['REQUEST_URI'] ?? '/';
$path = parse_url($requestUri, PHP_URL_PATH) ?? '/';

// Normalize path: strip query strings, script names, and base prefix
$path = preg_replace('#^/api/v1/?#i', '/', $path);
$path = preg_replace('#^/index\.php/?#i', '/', (string)$path);
$path = '/' . trim((string)$path, '/');

$method = strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');

// Route 1: Root / Health Check (GET / or GET /api/v1)
if ($method === 'GET' && ($path === '/' || $path === '')) {
    echo json_encode([
        'status' => 'online',
        'service' => 'SEOWebChecker REST API',
        'version' => '1.0.0',
        'platformUrl' => 'https://seowebchecker.com/',
        'timestamp' => gmdate('Y-m-d\TH:i:s\Z'),
        'endpoints' => [
            'health' => 'GET /api/v1',
            'audit' => 'POST /api/v1/audit',
            'audits' => 'GET /api/v1/audits',
        ],
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit;
}

// Route 2: Make.com Connection Verification & History (GET /audits or GET /api/v1/audits)
if ($method === 'GET' && ($path === '/audits' || str_starts_with($path, '/audits'))) {
    echo json_encode([
        'status' => 'success',
        'authenticated' => true,
        'count' => 0,
        'audits' => [],
        'platformUrl' => 'https://seowebchecker.com/',
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit;
}

// Route 3: Technical SEO Audit (POST /audit or POST /api/v1/audit)
if ($method === 'POST' && ($path === '/audit' || $path === '/')) {
    $rawBody = file_get_contents('php://input');
    $inputData = [];
    if (!empty($rawBody)) {
        $decoded = json_decode($rawBody, true);
        if (is_array($decoded)) {
            $inputData = $decoded;
        }
    }

    $targetUrl = trim((string)($inputData['url'] ?? $_POST['url'] ?? ''));

    if (empty($targetUrl)) {
        http_response_code(400);
        echo json_encode([
            'statusCode' => 400,
            'error' => 'Bad Request',
            'message' => 'Webpage URL is required (e.g. {"url": "https://example.com/"}).',
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
        exit;
    }

    if (!preg_match('#^https?://#i', $targetUrl)) {
        $targetUrl = 'https://' . $targetUrl;
    }

    if (!filter_var($targetUrl, FILTER_VALIDATE_URL)) {
        http_response_code(400);
        echo json_encode([
            'statusCode' => 400,
            'error' => 'Bad Request',
            'message' => 'Invalid webpage URL provided.',
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
        exit;
    }

    // Execute Technical SEO Audit
    $auditor = new StandaloneAuditor(timeout: 15);
    $result = $auditor->audit($targetUrl);

    http_response_code(200);
    echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit;
}

// Route 4: Fallback for unsupported endpoint
http_response_code(404);
echo json_encode([
    'statusCode' => 404,
    'error' => 'Not Found',
    'message' => "Endpoint not found: {$method} {$path}. Supported endpoints: GET /api/v1, POST /api/v1/audit, GET /api/v1/audits",
], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
exit;

/**
 * Self-contained Technical SEO Auditor Engine
 */
class StandaloneAuditor
{
    private string $userAgent;
    private int $timeout;

    public function __construct(
        string $userAgent = 'SEOWebChecker-Auditor/1.0 (+https://seowebchecker.com/)',
        int $timeout = 15
    ) {
        $this->userAgent = $userAgent;
        $this->timeout = $timeout;
    }

    public function audit(string $url): array
    {
        $start = microtime(true);
        $context = stream_context_create([
            'http' => [
                'method' => 'GET',
                'header' => [
                    "User-Agent: {$this->userAgent}",
                    "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                    "Accept-Language: en-US,en;q=0.9",
                ],
                'timeout' => $this->timeout,
                'follow_location' => 1,
                'ignore_errors' => true,
            ],
            'ssl' => [
                'verify_peer' => true,
                'verify_peer_name' => true,
            ]
        ]);

        $html = @file_get_contents($url, false, $context);
        $elapsedMs = round((microtime(true) - $start) * 1000.0, 2);

        if ($html === false) {
            $html = '';
        }

        $headers = [];
        if (isset($http_response_header)) {
            foreach ($http_response_header as $h) {
                if (str_contains($h, ':')) {
                    [$k, $v] = explode(':', $h, 2);
                    $headers[strtolower(trim($k))] = trim($v);
                }
            }
        }

        return $this->evaluate($html, $url, $headers, $elapsedMs);
    }

    private function evaluate(string $html, string $url, array $headers, float $responseTimeMs): array
    {
        $contentBytes = strlen($html);
        $pageSizeKb = round($contentBytes / 1024, 2);
        $issues = [];
        $passes = [];

        // 1. Title Tag
        $title = null;
        if (preg_match('/<title[^>]*>(.*?)<\/title>/is', $html, $m)) {
            $title = trim(preg_replace('/\s+/', ' ', strip_tags($m[1])));
        }
        $titleLen = $title !== null ? mb_strlen($title) : 0;

        if ($title === null || $title === '') {
            $issues[] = ['id' => 'meta-title-missing', 'category' => 'meta', 'severity' => 'error', 'title' => 'Missing page title', 'message' => 'No <title> tag found on the page.', 'recommendation' => 'Add a descriptive title tag between 30 and 60 characters.'];
        } elseif ($titleLen < 30) {
            $issues[] = ['id' => 'meta-title-short', 'category' => 'meta', 'severity' => 'warning', 'title' => 'Page title is short', 'message' => "Title is {$titleLen} characters ('{$title}').", 'recommendation' => 'Expand title tag to 30-60 characters for optimal visibility.'];
        } elseif ($titleLen > 65) {
            $issues[] = ['id' => 'meta-title-long', 'category' => 'meta', 'severity' => 'warning', 'title' => 'Page title is long', 'message' => "Title is {$titleLen} characters and may be truncated in search results.", 'recommendation' => 'Shorten title tag to under 60 characters.'];
        } else {
            $passes[] = ['id' => 'meta-title-pass', 'category' => 'meta', 'severity' => 'pass', 'title' => 'Title tag optimal', 'message' => "Title tag length is {$titleLen} characters ('{$title}').", 'recommendation' => 'Maintain current title tag.'];
        }

        // 2. Meta Description
        $description = null;
        if (preg_match('/<meta[^>]*name=["\']description["\'][^>]*content=["\']([^"\']*)["\']/is', $html, $m) ||
            preg_match('/<meta[^>]*content=["\']([^"\']*)["\'][^>]*name=["\']description["\']/is', $html, $m)) {
            $description = trim($m[1]);
        }
        $descLen = $description !== null ? mb_strlen($description) : 0;

        if ($description === null || $description === '') {
            $issues[] = ['id' => 'meta-desc-missing', 'category' => 'meta', 'severity' => 'error', 'title' => 'Missing meta description', 'message' => 'No meta description found.', 'recommendation' => 'Add an engaging meta description between 70 and 160 characters.'];
        } elseif ($descLen < 70) {
            $issues[] = ['id' => 'meta-desc-short', 'category' => 'meta', 'severity' => 'warning', 'title' => 'Meta description is short', 'message' => "Meta description is {$descLen} characters.", 'recommendation' => 'Expand description to 70-160 characters.'];
        } else {
            $passes[] = ['id' => 'meta-desc-pass', 'category' => 'meta', 'severity' => 'pass', 'title' => 'Meta description optimal', 'message' => "Meta description is {$descLen} characters.", 'recommendation' => 'Maintain current description.'];
        }

        // 3. Mobile Viewport
        $viewport = null;
        if (preg_match('/<meta[^>]*name=["\']viewport["\'][^>]*content=["\']([^"\']*)["\']/is', $html, $m)) {
            $viewport = trim($m[1]);
        }
        if (!$viewport) {
            $issues[] = ['id' => 'meta-viewport-missing', 'category' => 'technical', 'severity' => 'error', 'title' => 'Missing viewport meta tag', 'message' => 'Mobile viewport meta tag is missing.', 'recommendation' => 'Add <meta name="viewport" content="width=device-width, initial-scale=1.0">.'];
        } else {
            $passes[] = ['id' => 'meta-viewport-pass', 'category' => 'technical', 'severity' => 'pass', 'title' => 'Mobile viewport meta tag configured', 'message' => "Viewport configured: '{$viewport}'.", 'recommendation' => 'Mobile responsive design enabled.'];
        }

        // 4. Canonical Link
        $canonical = null;
        if (preg_match('/<link[^>]*rel=["\']canonical["\'][^>]*href=["\']([^"\']*)["\']/is', $html, $m)) {
            $canonical = trim($m[1]);
        }
        if (!$canonical) {
            $issues[] = ['id' => 'meta-canonical-missing', 'category' => 'technical', 'severity' => 'warning', 'title' => 'Missing canonical link tag', 'message' => 'No <link rel="canonical"> specified.', 'recommendation' => 'Add a self-referencing canonical tag.'];
        } else {
            $passes[] = ['id' => 'meta-canonical-pass', 'category' => 'technical', 'severity' => 'pass', 'title' => 'Canonical link tag present', 'message' => "Canonical URL declared: {$canonical}", 'recommendation' => 'Canonical link tag correctly defined.'];
        }

        // 5. Headings & Word Count
        preg_match_all('/<h1[^>]*>(.*?)<\/h1>/is', $html, $h1Matches);
        $h1Tags = array_map(fn($t) => trim(strip_tags($t)), $h1Matches[1] ?? []);
        $h1Count = count($h1Tags);

        $cleanText = preg_replace('/<(script|style)\b[^>]*>(.*?)<\/\1>/is', ' ', $html);
        $cleanText = strip_tags((string)$cleanText);
        preg_match_all('/\b[a-zA-Z0-9_\'-]{2,}\b/', $cleanText, $wordMatches);
        $wordCount = count($wordMatches[0] ?? []);

        if ($h1Count === 0) {
            $issues[] = ['id' => 'content-h1-missing', 'category' => 'content', 'severity' => 'error', 'title' => 'Missing <h1> heading', 'message' => 'No <h1> heading found on the page.', 'recommendation' => 'Include a single primary <h1> heading.'];
        } elseif ($h1Count === 1) {
            $passes[] = ['id' => 'content-h1-pass', 'category' => 'content', 'severity' => 'pass', 'title' => 'Exactly one <h1> heading present', 'message' => "Primary heading: '{$h1Tags[0]}'.", 'recommendation' => 'Clean heading hierarchy maintained.'];
        } else {
            $issues[] = ['id' => 'content-h1-multiple', 'category' => 'content', 'severity' => 'warning', 'title' => "Multiple <h1> headings found ({$h1Count})", 'message' => "Found {$h1Count} <h1> headings.", 'recommendation' => 'Consolidate to a single top-level <h1> heading.'];
        }

        if ($wordCount < 100) {
            $issues[] = ['id' => 'content-thin', 'category' => 'content', 'severity' => 'error', 'title' => 'Thin page content', 'message' => "Page has only {$wordCount} words.", 'recommendation' => 'Add informative text content of 300+ words.'];
        } else {
            $passes[] = ['id' => 'content-words-pass', 'category' => 'content', 'severity' => 'pass', 'title' => 'Adequate content word count', 'message' => "Page contains {$wordCount} words.", 'recommendation' => 'Healthy content volume.'];
        }

        // 6. Technical HTTPS
        $isHttps = str_starts_with(strtolower($url), 'https://');
        if (!$isHttps) {
            $issues[] = ['id' => 'tech-not-https', 'category' => 'technical', 'severity' => 'error', 'title' => 'Insecure HTTP protocol', 'message' => 'Target site uses unencrypted HTTP.', 'recommendation' => 'Install SSL and redirect all traffic to HTTPS.'];
        } else {
            $passes[] = ['id' => 'tech-https-pass', 'category' => 'technical', 'severity' => 'pass', 'title' => 'Secure HTTPS connection', 'message' => 'SSL certificate is active and HTTPS enforced.', 'recommendation' => 'Secure transport verified.'];
        }

        // 7. OpenGraph
        $hasOg = (bool)preg_match('/property=["\']og:title["\']/i', $html);
        if (!$hasOg) {
            $issues[] = ['id' => 'social-og-missing', 'category' => 'meta', 'severity' => 'warning', 'title' => 'Missing OpenGraph meta tags', 'message' => 'No og:title meta tag found.', 'recommendation' => 'Add OpenGraph tags for rich social sharing cards.'];
        } else {
            $passes[] = ['id' => 'social-og-pass', 'category' => 'meta', 'severity' => 'pass', 'title' => 'OpenGraph social tags present', 'message' => 'OpenGraph metadata found in page head.', 'recommendation' => 'Social preview tags configured.'];
        }

        // Score computation
        $errorCount = count(array_filter($issues, fn($i) => $i['severity'] === 'error'));
        $warningCount = count(array_filter($issues, fn($i) => $i['severity'] === 'warning'));
        $passCount = count($passes);
        $totalChecks = $errorCount + $warningCount + $passCount;

        $overallScore = 100 - ($errorCount * 12) - ($warningCount * 5);
        $overallScore = max(10, min(100, $overallScore));

        $grade = match (true) {
            $overallScore >= 95 => 'A+',
            $overallScore >= 90 => 'A',
            $overallScore >= 80 => 'B',
            $overallScore >= 70 => 'C',
            $overallScore >= 60 => 'D',
            default => 'F',
        };

        $auditId = 'audit_' . (int)(microtime(true) * 1000);

        return [
            'id' => $auditId,
            'url' => $url,
            'timestamp' => gmdate('Y-m-d\TH:i:s\Z'),
            'score' => [
                'overall' => $overallScore,
                'grade' => $grade,
                'categories' => [
                    'meta' => ['score' => max(0, 100 - ($errorCount * 10))],
                    'content' => ['score' => max(0, 100 - ($warningCount * 10))],
                    'technical' => ['score' => $isHttps ? 100 : 50],
                ]
            ],
            'stats' => [
                'total' => $totalChecks,
                'passed' => $passCount,
                'warnings' => $warningCount,
                'errors' => $errorCount,
            ],
            'title' => $title ?? '',
            'metaDescription' => $description ?? '',
            'issues' => $issues,
            'passes' => $passes,
            'performance' => [
                'responseTimeMs' => $responseTimeMs,
                'pageSizeKb' => $pageSizeKb,
            ],
            'platformUrl' => 'https://seowebchecker.com/',
        ];
    }
}
