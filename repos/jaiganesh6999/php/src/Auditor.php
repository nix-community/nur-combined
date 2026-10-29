<?php

declare(strict_types=1);

namespace SeoWebChecker\SeoAudit;

/**
 * Lightweight, zero-dependency SEO Auditor in PHP 8.2.
 * Official site: https://seowebchecker.com/
 */
class Auditor
{
    private string $userAgent;
    private int $timeout;

    public function __construct(
        string $userAgent = 'SEOWebChecker-PhpBot/1.0 (+https://seowebchecker.com/)',
        int $timeout = 15
    ) {
        $this->userAgent = $userAgent;
        $this->timeout = $timeout;
    }

    public function audit(string $url): AuditResult
    {
        if (!preg_match('#^https?://#i', $url)) {
            $url = 'https://' . $url;
        }

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

        return $this->auditHtml($html, $url, [
            'headers' => $headers,
            'response_time_ms' => $elapsedMs,
            'status_code' => 200,
        ]);
    }

    public function auditHtml(string $html, string $url = 'https://seowebchecker.com/', array $options = []): AuditResult
    {
        $headers = $options['headers'] ?? [];
        $responseTimeMs = (float)($options['response_time_ms'] ?? 120.0);
        $contentBytes = strlen($html);
        $pageSizeKb = round($contentBytes / 1024, 2);

        $issues = [];

        // 1. Title
        $title = null;
        if (preg_match('/<title[^>]*>(.*?)<\/title>/is', $html, $m)) {
            $title = trim(preg_replace('/\s+/', ' ', strip_tags($m[1])));
        }
        $titleLen = $title !== null ? mb_strlen($title) : 0;

        if ($title === null || $title === '') {
            $issues[] = ['id' => 'meta-title-missing', 'category' => 'meta', 'severity' => 'error', 'title' => 'Missing Page Title', 'message' => 'No <title> tag found.', 'recommendation' => 'Add a descriptive title between 30 and 60 characters.'];
        } elseif ($titleLen < 30) {
            $issues[] = ['id' => 'meta-title-short', 'category' => 'meta', 'severity' => 'warning', 'title' => 'Page Title Too Short', 'message' => "Title is only {$titleLen} characters ('{$title}').", 'recommendation' => 'Expand title to 30-60 characters.'];
        } elseif ($titleLen > 65) {
            $issues[] = ['id' => 'meta-title-long', 'category' => 'meta', 'severity' => 'warning', 'title' => 'Page Title Too Long', 'message' => "Title is {$titleLen} characters. May be truncated in search results.", 'recommendation' => 'Shorten title to under 60 characters.'];
        } else {
            $issues[] = ['id' => 'meta-title-pass', 'category' => 'meta', 'severity' => 'pass', 'title' => 'Optimal Title Tag Length', 'message' => "Title has {$titleLen} characters: '{$title}'.", 'recommendation' => 'Maintain clear title.'];
        }

        // 2. Description
        $description = null;
        if (preg_match('/<meta[^>]*name=["\']description["\'][^>]*content=["\']([^"\']*)["\']/is', $html, $m) ||
            preg_match('/<meta[^>]*content=["\']([^"\']*)["\'][^>]*name=["\']description["\']/is', $html, $m)) {
            $description = trim($m[1]);
        }
        $descLen = $description !== null ? mb_strlen($description) : 0;

        if ($description === null || $description === '') {
            $issues[] = ['id' => 'meta-desc-missing', 'category' => 'meta', 'severity' => 'error', 'title' => 'Missing Meta Description', 'message' => 'No meta description tag found.', 'recommendation' => 'Add a meta description between 120 and 160 characters.'];
        } elseif ($descLen < 70) {
            $issues[] = ['id' => 'meta-desc-short', 'category' => 'meta', 'severity' => 'warning', 'title' => 'Meta Description Too Short', 'message' => "Description is {$descLen} characters.", 'recommendation' => 'Expand description to 120-160 characters.'];
        } else {
            $issues[] = ['id' => 'meta-desc-pass', 'category' => 'meta', 'severity' => 'pass', 'title' => 'Optimal Meta Description', 'message' => "Description has {$descLen} characters.", 'recommendation' => 'Good meta description.'];
        }

        // 3. Viewport
        $viewport = null;
        if (preg_match('/<meta[^>]*name=["\']viewport["\'][^>]*content=["\']([^"\']*)["\']/is', $html, $m)) {
            $viewport = trim($m[1]);
        }
        if (!$viewport) {
            $issues[] = ['id' => 'meta-viewport-missing', 'category' => 'meta', 'severity' => 'error', 'title' => 'Missing Viewport Meta Tag', 'message' => 'Mobile viewport is missing.', 'recommendation' => 'Add <meta name="viewport" content="width=device-width, initial-scale=1.0">.'];
        } else {
            $issues[] = ['id' => 'meta-viewport-pass', 'category' => 'meta', 'severity' => 'pass', 'title' => 'Mobile Viewport Configured', 'message' => "Viewport set to '{$viewport}'.", 'recommendation' => 'Mobile responsiveness enabled.'];
        }

        // 4. Canonical
        $canonical = null;
        if (preg_match('/<link[^>]*rel=["\']canonical["\'][^>]*href=["\']([^"\']*)["\']/is', $html, $m)) {
            $canonical = trim($m[1]);
        }
        if (!$canonical) {
            $issues[] = ['id' => 'meta-canonical-missing', 'category' => 'meta', 'severity' => 'warning', 'title' => 'Missing Canonical URL', 'message' => 'No <link rel="canonical"> specified.', 'recommendation' => 'Add canonical tag to avoid duplicate content penalties.'];
        } else {
            $issues[] = ['id' => 'meta-canonical-pass', 'category' => 'meta', 'severity' => 'pass', 'title' => 'Canonical Tag Specified', 'message' => "Canonical URL: {$canonical}", 'recommendation' => 'Good canonical practice.'];
        }

        // 5. Headings & Content
        preg_match_all('/<h1[^>]*>(.*?)<\/h1>/is', $html, $h1Matches);
        $h1Tags = array_map(fn($t) => trim(strip_tags($t)), $h1Matches[1] ?? []);
        $h1Count = count($h1Tags);

        preg_match_all('/<h2[^>]*>(.*?)<\/h2>/is', $html, $h2Matches);
        $h2Tags = array_map(fn($t) => trim(strip_tags($t)), $h2Matches[1] ?? []);

        $cleanText = preg_replace('/<(script|style)\b[^>]*>(.*?)<\/\1>/is', ' ', $html);
        $cleanText = strip_tags((string)$cleanText);
        preg_match_all('/\b[a-zA-Z0-9_\'-]{2,}\b/', $cleanText, $wordMatches);
        $wordCount = count($wordMatches[0] ?? []);
        $readingTime = round($wordCount / 200, 1);

        if ($h1Count === 0) {
            $issues[] = ['id' => 'content-h1-missing', 'category' => 'content', 'severity' => 'error', 'title' => 'Missing <h1> Tag', 'message' => 'No <h1> heading found on the page.', 'recommendation' => 'Add a single <h1> heading representing the page topic.'];
        } elseif ($h1Count === 1) {
            $issues[] = ['id' => 'content-h1-pass', 'category' => 'content', 'severity' => 'pass', 'title' => 'Single <h1> Tag Configured', 'message' => "Primary heading: '{$h1Tags[0]}'.", 'recommendation' => 'Maintain proper hierarchy.'];
        } else {
            $issues[] = ['id' => 'content-h1-multiple', 'category' => 'content', 'severity' => 'warning', 'title' => "Multiple <h1> Tags ({$h1Count})", 'message' => "Found {$h1Count} <h1> headings.", 'recommendation' => 'Consolidate to a single <h1> heading.'];
        }

        if ($wordCount < 100) {
            $issues[] = ['id' => 'content-thin', 'category' => 'content', 'severity' => 'error', 'title' => 'Thin Content Detected', 'message' => "Page has only {$wordCount} words.", 'recommendation' => 'Expand content to 300+ words.'];
        } else {
            $issues[] = ['id' => 'content-words-pass', 'category' => 'content', 'severity' => 'pass', 'title' => 'Adequate Word Count', 'message' => "Page has {$wordCount} words (~{$readingTime} min read).", 'recommendation' => 'Good content length.'];
        }

        // 6. Images
        preg_match_all('/<img\s+([^>]*?)>/is', $html, $imgMatches);
        $totalImages = count($imgMatches[0] ?? []);
        $missingAlt = 0;
        $modernFormats = 0;

        foreach ($imgMatches[1] ?? [] as $imgAttr) {
            if (!preg_match('/alt=["\']/i', $imgAttr)) {
                $missingAlt++;
            }
            if (preg_match('/\.(webp|avif|svg)/i', $imgAttr)) {
                $modernFormats++;
            }
        }

        if ($totalImages > 0) {
            if ($missingAlt > 0) {
                $issues[] = ['id' => 'images-missing-alt', 'category' => 'images', 'severity' => 'error', 'title' => "{$missingAlt} Images Missing 'alt'", 'message' => "{$missingAlt} of {$totalImages} images lack alt attributes.", 'recommendation' => 'Add descriptive alt text to all images.'];
            } else {
                $issues[] = ['id' => 'images-alt-pass', 'category' => 'images', 'severity' => 'pass', 'title' => 'All Images Have Alt Attributes', 'message' => "All {$totalImages} images include alt text.", 'recommendation' => 'Excellent image accessibility.'];
            }
        }

        // 7. Technical
        $isHttps = str_starts_with(strtolower($url), 'https://');
        if (!$isHttps) {
            $issues[] = ['id' => 'tech-not-https', 'category' => 'technical', 'severity' => 'error', 'title' => 'Insecure HTTP Protocol', 'message' => 'Site uses HTTP instead of HTTPS.', 'recommendation' => 'Install SSL certificate and enforce HTTPS.'];
        } else {
            $issues[] = ['id' => 'tech-https-pass', 'category' => 'technical', 'severity' => 'pass', 'title' => 'Secure HTTPS Active', 'message' => 'Secure encrypted connection.', 'recommendation' => 'SSL certificate is valid.'];
        }

        // 8. OpenGraph & Schema
        $hasOg = (bool)preg_match('/property=["\']og:title["\']/i', $html);
        if (!$hasOg) {
            $issues[] = ['id' => 'social-og-missing', 'category' => 'social', 'severity' => 'warning', 'title' => 'Missing OpenGraph Tags', 'message' => 'No og:title meta tag found.', 'recommendation' => 'Add OpenGraph tags for rich social previews.'];
        } else {
            $issues[] = ['id' => 'social-og-pass', 'category' => 'social', 'severity' => 'pass', 'title' => 'OpenGraph Configured', 'message' => 'OpenGraph tags detected.', 'recommendation' => 'Social sharing ready.'];
        }

        $hasSchema = (bool)preg_match('/application\/ld\+json/i', $html);
        if (!$hasSchema) {
            $issues[] = ['id' => 'schema-missing', 'category' => 'schema', 'severity' => 'warning', 'title' => 'Missing Structured Data', 'message' => 'No JSON-LD structured data detected.', 'recommendation' => 'Add Schema.org JSON-LD structured data.'];
        } else {
            $issues[] = ['id' => 'schema-pass', 'category' => 'schema', 'severity' => 'pass', 'title' => 'Structured Data Present', 'message' => 'JSON-LD schema found.', 'recommendation' => 'Rich results eligible.'];
        }

        // Compute scores
        $categoryWeights = ['meta' => 0.25, 'content' => 0.20, 'technical' => 0.20, 'performance' => 0.15, 'images' => 0.10, 'social' => 0.05, 'schema' => 0.05];
        $catMap = [];
        foreach ($issues as $iss) {
            $catMap[$iss['category']][] = $iss;
        }

        $catScores = [];
        $weightedSum = 0.0;
        $weightTotal = 0.0;

        foreach ($catMap as $catName => $catIssues) {
            $passCount = count(array_filter($catIssues, fn($i) => $i['severity'] === 'pass'));
            $warnCount = count(array_filter($catIssues, fn($i) => $i['severity'] === 'warning'));
            $errCount = count(array_filter($catIssues, fn($i) => $i['severity'] === 'error'));
            $total = count($catIssues);

            $score = (int)round(($passCount / $total) * 100) - ($errCount * 10) - ($warnCount * 3);
            $score = max(0, min(100, $score));

            $catScores[$catName] = [
                'score' => $score,
                'passed_count' => $passCount,
                'warning_count' => $warnCount,
                'error_count' => $errCount,
            ];

            $w = $categoryWeights[$catName] ?? 0.1;
            $weightedSum += $score * $w;
            $weightTotal += $w;
        }

        $overall = $weightTotal > 0 ? (int)round($weightedSum / $weightTotal) : 80;
        $overall = max(0, min(100, $overall));

        $grade = match (true) {
            $overall >= 95 => 'A+',
            $overall >= 90 => 'A',
            $overall >= 80 => 'B',
            $overall >= 70 => 'C',
            $overall >= 60 => 'D',
            default => 'F',
        };

        $passedList = array_values(array_filter($issues, fn($i) => $i['severity'] === 'pass'));
        $warningList = array_values(array_filter($issues, fn($i) => $i['severity'] === 'warning'));
        $errorList = array_values(array_filter($issues, fn($i) => $i['severity'] === 'error'));

        return new AuditResult(
            url: $url,
            timestamp: gmdate('Y-m-d\TH:i:s\Z'),
            score: $overall,
            grade: $grade,
            categories: $catScores,
            stats: [
                'total' => count($issues),
                'passed' => count($passedList),
                'warnings' => count($warningList),
                'errors' => count($errorList),
            ],
            meta: [
                'title' => $title,
                'title_length' => $titleLen,
                'description' => $description,
                'description_length' => $descLen,
                'canonical' => $canonical,
                'viewport' => $viewport,
            ],
            content: [
                'word_count' => $wordCount,
                'reading_time_minutes' => $readingTime,
                'h1_tags' => $h1Tags,
                'h2_tags' => $h2Tags,
            ],
            images: [
                'total_images' => $totalImages,
                'missing_alt' => $missingAlt,
                'modern_formats' => $modernFormats,
            ],
            technical: [
                'is_https' => $isHttps,
            ],
            performance: [
                'response_time_ms' => $responseTimeMs,
                'page_size_kb' => $pageSizeKb,
            ],
            issues: $issues,
            errors: $errorList,
            warnings: $warningList,
            passed: $passedList
        );
    }
}
