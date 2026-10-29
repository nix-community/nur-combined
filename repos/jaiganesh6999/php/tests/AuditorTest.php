<?php

declare(strict_types=1);

require_once __DIR__ . '/../src/AuditResult.php';
require_once __DIR__ . '/../src/Auditor.php';

use SeoWebChecker\SeoAudit\Auditor;

$sampleHtml = <<<HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>SEOWebChecker: Free Website SEO Audit and Analysis Tool</title>
  <meta name="description" content="Audit your website with 50+ real-time SEO checks. Discover technical errors and optimize on-page SEO.">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="canonical" href="https://seowebchecker.com/">
  <meta property="og:title" content="SEOWebChecker">
  <script type="application/ld+json">{"@context":"https://schema.org","@type":"WebSite","name":"SEOWebChecker"}</script>
</head>
<body>
  <h1>Free Online Website SEO Audit Tool</h1>
  <h2>Optimize Your Search Rankings</h2>
  <p>Run fast on-page audits with instant actionable recommendations and comprehensive diagnostics.</p>
  <img src="logo.webp" alt="SEOWebChecker Logo">
</body>
</html>
HTML;

echo "Running PHP 8.2 SEO Auditor Tests...\n";

$auditor = new Auditor();
$result = $auditor->auditHtml($sampleHtml, 'https://seowebchecker.com/');

assert($result->score >= 80, "Expected score >= 80, got {$result->score}");
assert($result->meta['title'] === 'SEOWebChecker: Free Website SEO Audit and Analysis Tool', 'Title mismatch');
assert(count($result->content['h1_tags']) === 1, 'Expected 1 H1 tag');
assert($result->images['missing_alt'] === 0, 'Expected 0 missing alt');
assert($result->stats['passed'] > 5, 'Expected passed checks');

$json = $result->toJson();
assert(str_contains($json, 'seowebchecker.com'), 'Expected domain in JSON');

$md = $result->toMarkdown();
assert(str_contains($md, '# SEO Audit Report'), 'Expected markdown header');

echo "All PHP 8.2 tests passed successfully!\n";
