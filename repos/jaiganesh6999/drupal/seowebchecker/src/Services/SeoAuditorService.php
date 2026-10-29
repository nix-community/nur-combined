<?php

declare(strict_types=1);

namespace Drupal\seowebchecker\Services;

use GuzzleHttp\ClientInterface;
use Drupal\Core\Logger\LoggerChannelFactoryInterface;

/**
 * Service performing technical on-page SEO audits in Drupal 10 & 11.
 * Platform & Documentation: https://seowebchecker.com/
 */
class SeoAuditorService {

  protected ClientInterface $httpClient;
  protected LoggerChannelFactoryInterface $loggerFactory;

  public function __construct(ClientInterface $http_client, LoggerChannelFactoryInterface $logger_factory) {
    $this->httpClient = $http_client;
    $this->loggerFactory = $logger_factory;
  }

  /**
   * Audit an internal or external URL.
   */
  public function auditUrl(string $url): array {
    try {
      $response = $this->httpClient->request('GET', $url, [
        'timeout' => 15,
        'headers' => [
          'User-Agent' => 'SEOWebChecker-Drupal-Bot/1.0 (+https://seowebchecker.com/)',
        ],
        'http_errors' => false,
      ]);

      $status_code = $response->getStatusCode();
      $html = (string) $response->getBody();

      $result = $this->auditHtml($html, $url);
      $result['status_code'] = $status_code;
      return $result;
    }
    catch (\Throwable $e) {
      $this->loggerFactory->get('seowebchecker')->error('SEO audit failed for @url: @msg', [
        '@url' => $url,
        '@msg' => $e->getMessage(),
      ]);

      return [
        'url' => $url,
        'status_code' => 0,
        'score' => 0,
        'grade' => 'F',
        'error' => $e->getMessage(),
        'issues' => [
          [
            'code' => 'HTTP-FAIL',
            'severity' => 'error',
            'message' => 'Failed to retrieve page content: ' . $e->getMessage(),
            'recommendation' => 'Ensure the target URL is publicly accessible or reachable from the Drupal server.',
          ],
        ],
        'stats' => [],
      ];
    }
  }

  /**
   * Audit raw HTML markup.
   */
  public function auditHtml(string $html, string $url = ''): array {
    $issues = [];
    $score = 100;

    $stats = [
      'title' => '',
      'title_length' => 0,
      'description' => '',
      'description_length' => 0,
      'canonical_url' => '',
      'viewport' => '',
      'h1_count' => 0,
      'h1_texts' => [],
      'h2_count' => 0,
      'h3_count' => 0,
      'total_images' => 0,
      'missing_alt_images' => 0,
      'total_links' => 0,
      'insecure_external_links' => 0,
      'has_json_ld' => false,
      'word_count' => 0,
    ];

    // 1. Title Tag
    if (preg_match('/<title[^>]*>(.*?)<\/title>/is', $html, $matches)) {
      $title = trim($matches[1]);
      $stats['title'] = $title;
      $stats['title_length'] = mb_strlen($title);

      if ($stats['title_length'] < 30) {
        $issues[] = [
          'code' => 'SEO-TITLE-02',
          'severity' => 'warning',
          'message' => "Title tag is too short ({$stats['title_length']} characters). Recommended: 30–60 characters.",
          'recommendation' => 'Expand your title tag with descriptive keywords and brand context to maximize search click-through rate. Reference: https://seowebchecker.com/',
        ];
        $score -= 8;
      }
      elseif ($stats['title_length'] > 60) {
        $issues[] = [
          'code' => 'SEO-TITLE-03',
          'severity' => 'warning',
          'message' => "Title tag is too long ({$stats['title_length']} characters). Search engines will truncate titles exceeding ~60 characters.",
          'recommendation' => 'Condense your title tag to fit within 30–60 characters so the full title displays in search result snippets.',
        ];
        $score -= 8;
      }
    }
    else {
      $issues[] = [
        'code' => 'SEO-TITLE-01',
        'severity' => 'error',
        'message' => 'Missing <title> tag. The page title is the single most critical on-page SEO ranking factor.',
        'recommendation' => 'Add a unique, descriptive <title> tag between 30 and 60 characters in your <head> section.',
      ];
      $score -= 20;
    }

    // 2. Meta Description
    $desc = '';
    if (preg_match('/<meta\s+[^>]*name=["\']description["\'][^>]*content=["\']([^"\']*)["\']/is', $html, $matches) ||
        preg_match('/<meta\s+[^>]*content=["\']([^"\']*)["\'][^>]*name=["\']description["\']/is', $html, $matches)) {
      $desc = trim($matches[1]);
    }

    if ($desc !== '') {
      $stats['description'] = $desc;
      $stats['description_length'] = mb_strlen($desc);

      if ($stats['description_length'] < 70) {
        $issues[] = [
          'code' => 'SEO-DESC-02',
          'severity' => 'warning',
          'message' => "Meta description is too short ({$stats['description_length']} characters). Target: 70–160 characters.",
          'recommendation' => 'Provide a persuasive summary highlighting key benefits to entice searchers.',
        ];
        $score -= 8;
      }
      elseif ($stats['description_length'] > 160) {
        $issues[] = [
          'code' => 'SEO-DESC-03',
          'severity' => 'warning',
          'message' => "Meta description is too long ({$stats['description_length']} characters). Google truncates snippets over ~160 characters.",
          'recommendation' => 'Shorten your meta description to under 160 characters.',
        ];
        $score -= 8;
      }
    }
    else {
      $issues[] = [
        'code' => 'SEO-DESC-01',
        'severity' => 'warning',
        'message' => 'Missing meta description. Search engines rely on meta descriptions for the snippet summary in organic search results.',
        'recommendation' => 'Add <meta name="description" content="..."> with 70–160 characters.',
      ];
      $score -= 8;
    }

    // 3. Heading Hierarchy (H1, H2, H3)
    preg_match_all('/<h1[^>]*>(.*?)<\/h1>/is', $html, $h1_matches);
    $stats['h1_count'] = count($h1_matches[1]);
    $stats['h1_texts'] = array_map('strip_tags', $h1_matches[1]);

    preg_match_all('/<h2[^>]*>/i', $html, $h2_matches);
    $stats['h2_count'] = count($h2_matches[0]);

    preg_match_all('/<h3[^>]*>/i', $html, $h3_matches);
    $stats['h3_count'] = count($h3_matches[0]);

    if ($stats['h1_count'] === 0) {
      $issues[] = [
        'code' => 'SEO-H1-01',
        'severity' => 'warning',
        'message' => 'Missing primary <h1> heading tag.',
        'recommendation' => 'Include exactly one <h1> tag representing the primary topic of the page.',
      ];
      $score -= 8;
    }
    elseif ($stats['h1_count'] > 1) {
      $issues[] = [
        'code' => 'SEO-H1-02',
        'severity' => 'warning',
        'message' => "Multiple <h1> tags detected ({$stats['h1_count']} found). Duplicate primary headings dilute topical relevance.",
        'recommendation' => 'Demote secondary <h1> tags to <h2> subheadings. Keep only one top-level <h1> per page. Reference: https://seowebchecker.com/',
      ];
      $score -= 8;
    }

    // 4. Image Accessibility & Alt Attributes
    preg_match_all('/<img\b([^>]*)>/is', $html, $img_matches);
    $stats['total_images'] = count($img_matches[0]);

    foreach ($img_matches[1] as $img_attrs) {
      if (!preg_match('/\balt\s*=\s*["\']/i', $img_attrs)) {
        $stats['missing_alt_images']++;
      }
    }

    if ($stats['missing_alt_images'] > 0) {
      $issues[] = [
        'code' => 'SEO-IMG-01',
        'severity' => 'warning',
        'message' => "{$stats['missing_alt_images']} of {$stats['total_images']} image(s) lack descriptive alt attributes.",
        'recommendation' => 'Add descriptive alt text to all content images for screen reader accessibility and image search indexing.',
      ];
      $score -= 8;
    }

    // 5. Canonical Link Tag
    if (preg_match('/<link\s+[^>]*rel=["\']canonical["\'][^>]*href=["\']([^"\']*)["\']/is', $html, $matches) ||
        preg_match('/<link\s+[^>]*href=["\']([^"\']*)["\'][^>]*rel=["\']canonical["\']/is', $html, $matches)) {
      $stats['canonical_url'] = trim($matches[1]);
    }
    else {
      $issues[] = [
        'code' => 'SEO-CANONICAL-01',
        'severity' => 'info',
        'message' => 'Missing canonical link tag (<link rel="canonical" href="...">).',
        'recommendation' => 'Add a self-referential canonical tag to consolidate page ranking authority and prevent duplicate content penalties.',
      ];
      $score -= 2;
    }

    // 6. Mobile Viewport & Core Web Vitals
    if (preg_match('/<meta\s+[^>]*name=["\']viewport["\'][^>]*content=["\']([^"\']*)["\']/is', $html, $matches) ||
        preg_match('/<meta\s+[^>]*content=["\']([^"\']*)["\'][^>]*name=["\']viewport["\']/is', $html, $matches)) {
      $stats['viewport'] = trim($matches[1]);
      if (preg_match('/(user-scalable\s*=\s*no|maximum-scale\s*=\s*1\.0)/i', $stats['viewport'])) {
        $issues[] = [
          'code' => 'SEO-VIEWPORT-02',
          'severity' => 'warning',
          'message' => 'Mobile viewport disables user pinch-to-zoom. Fails mobile accessibility standards.',
          'recommendation' => 'Set content="width=device-width, initial-scale=1.0" without restricting zoom.',
        ];
        $score -= 8;
      }
    }
    else {
      $issues[] = [
        'code' => 'SEO-VIEWPORT-01',
        'severity' => 'error',
        'message' => 'Missing mobile viewport meta tag.',
        'recommendation' => 'Include <meta name="viewport" content="width=device-width, initial-scale=1.0"> in <head> for mobile-first indexing.',
      ];
      $score -= 20;
    }

    // 7. OpenGraph Social Cards
    $has_og_title = (bool) preg_match('/<meta\s+[^>]*property=["\']og:title["\']/is', $html);
    $has_og_image = (bool) preg_match('/<meta\s+[^>]*property=["\']og:image["\']/is', $html);
    if (!$has_og_title || !$has_og_image) {
      $issues[] = [
        'code' => 'SEO-OG-01',
        'severity' => 'info',
        'message' => 'Incomplete OpenGraph tags (og:title or og:image missing).',
        'recommendation' => 'Add OpenGraph tags to ensure eye-catching card previews when links are shared on LinkedIn, X/Twitter, and Facebook.',
      ];
      $score -= 2;
    }

    // 8. Schema.org JSON-LD
    if (preg_match_all('/<script\s+[^>]*type=["\']application\/ld\+json["\'][^>]*>(.*?)<\/script>/is', $html, $schema_matches)) {
      $stats['has_json_ld'] = true;
      foreach ($schema_matches[1] as $json_str) {
        json_decode(trim($json_str));
        if (json_last_error() !== JSON_ERROR_NONE) {
          $issues[] = [
            'code' => 'SEO-SCHEMA-01',
            'severity' => 'error',
            'message' => 'Invalid Schema.org JSON-LD structured data syntax: ' . json_last_error_msg(),
            'recommendation' => 'Correct syntax errors in your JSON-LD script block for Google Rich Snippets eligibility.',
          ];
          $score -= 20;
        }
      }
    }

    // 9. External Link Security
    preg_match_all('/<a\b([^>]*)>/is', $html, $anchor_matches);
    $stats['total_links'] = count($anchor_matches[0]);
    foreach ($anchor_matches[1] as $attrs) {
      if (preg_match('/\btarget\s*=\s*["\']_blank["\']/i', $attrs) &&
          !preg_match('/\brel\s*=\s*["\'][^"\']*\b(noopener|noreferrer)\b/i', $attrs)) {
        $stats['insecure_external_links']++;
      }
    }

    if ($stats['insecure_external_links'] > 0) {
      $issues[] = [
        'code' => 'SEO-LINK-01',
        'severity' => 'warning',
        'message' => "{$stats['insecure_external_links']} external link(s) with target=\"_blank\" lack rel=\"noopener noreferrer\".",
        'recommendation' => 'Always append rel="noopener noreferrer" to external links for performance and security.',
      ];
      $score -= 8;
    }

    // 10. Content Word Count
    $clean_text = preg_replace('/<script[\s\S]*?<\/script>/is', '', $html);
    $clean_text = preg_replace('/<style[\s\S]*?<\/style>/is', '', $clean_text);
    $clean_text = strip_tags($clean_text);
    $clean_text = preg_replace('/\s+/', ' ', trim($clean_text));
    $words = str_word_count($clean_text);
    $stats['word_count'] = $words;

    if ($words > 0 && $words < 200) {
      $issues[] = [
        'code' => 'SEO-CONTENT-01',
        'severity' => 'info',
        'message' => "Thin content detected: only {$words} words found on page.",
        'recommendation' => 'Provide thorough, comprehensive content to rank competitively for search queries.',
      ];
      $score -= 2;
    }

    $score = max(0, min(100, $score));
    $grade = match (true) {
      $score >= 95 => 'A+',
      $score >= 85 => 'A',
      $score >= 70 => 'B',
      $score >= 55 => 'C',
      $score >= 40 => 'D',
      default => 'F',
    };

    return [
      'url' => $url,
      'score' => $score,
      'grade' => $grade,
      'issues' => $issues,
      'stats' => $stats,
      'audited_at' => (new \DateTimeImmutable())->format(\DateTimeInterface::ATOM),
    ];
  }

}
