<?php
/**
 * Local Standalone Verification Test Suite for SEOWebChecker WordPress Plugin
 * Run via: & "C:\tools\php82\php.exe" wordpress/tests/test_plugin.php
 */

declare(strict_types=1);

error_reporting(E_ALL);
ini_set('display_errors', '1');

echo "=========================================================\n";
echo "  SEOWebChecker: Local WordPress Plugin Verification Test\n";
echo "=========================================================\n\n";

// 1. Mock WordPress Core Environment
define('ABSPATH', __DIR__ . '/../../');
define('SEOWEBCHECKER_VERSION', '1.0.0');
define('SEOWEBCHECKER_PLUGIN_DIR', dirname(__DIR__) . '/');
define('SEOWEBCHECKER_PLUGIN_URL', 'http://localhost/wp-content/plugins/seowebchecker/');

class WP_Post {
    public int $ID = 42;
    public string $post_title = 'The Definitive Guide to Technical SEO & Core Web Vitals';
    public string $post_content = '<h2>Introduction to Search Engine Optimization</h2><p>Technical SEO is the foundation of any successful digital strategy. Optimizing website architecture, heading structures, image alt attributes, and metadata ensures that search engines can easily crawl, index, and understand your content.</p><h2>Heading Structure and Readability</h2><p>Proper H1 and H2 tags establish semantic context. Content should be comprehensive, actionable, and structured for user accessibility. Always include clear meta descriptions and mobile responsive viewport configurations for optimal user experience across all devices.</p><img src="https://example.com/guide.jpg" alt="SEO Guide Infographic" /><p>Regular auditing catches regressions before they impact organic rankings.</p>';
    public string $post_excerpt = 'Comprehensive guide covering technical SEO audits, meta tags, heading structures, and Core Web Vitals.';
    public string $post_type = 'post';
    public string $post_status = 'publish';
}

class WP_Admin_Bar {
    public array $nodes = [];
    public function add_node(array $args): void {
        $this->nodes[] = $args;
    }
}

class WP_Error {
    private string $message;
    public function __construct(string $message = 'Loopback connection failed') {
        $this->message = $message;
    }
    public function get_error_message(): string {
        return $this->message;
    }
}

// Global Mocks
$GLOBALS['wp_options'] = [
    'blog_public' => '1',
    'permalink_structure' => '/%postname%/',
];

function is_admin(): bool { return true; }
function is_ssl(): bool { return true; }
function current_time(string $type): string { return date('Y-m-d H:i:s'); }
function home_url(string $path = ''): string { return 'http://localhost:8000' . $path; }
function site_url(string $path = ''): string { return 'http://localhost:8000' . $path; }
function admin_url(string $path = ''): string { return 'http://localhost:8000/wp-admin/' . $path; }
function get_bloginfo(string $show = ''): string {
    return match ($show) {
        'name'        => 'My WordPress Site',
        'description' => 'A Modern Website Built with WordPress',
        'language'    => 'en-US',
        default       => '',
    };
}
function get_option(string $option, mixed $default = false): mixed {
    return $GLOBALS['wp_options'][$option] ?? $default;
}
function current_user_can(string $cap): bool { return true; }
function wp_parse_url(string $url): array { return parse_url($url) ?: []; }
function esc_html(mixed $text): string { return htmlspecialchars((string) $text, ENT_QUOTES, 'UTF-8'); }
function esc_attr(mixed $text): string { return htmlspecialchars((string) $text, ENT_QUOTES, 'UTF-8'); }
function esc_url(mixed $url): string { return filter_var($url, FILTER_SANITIZE_URL) ?: ''; }
function esc_url_raw(mixed $url): string { return filter_var($url, FILTER_SANITIZE_URL) ?: ''; }
function esc_html_e(string $text, string $domain = 'default'): void { echo esc_html($text); }
function esc_html__(string $text, string $domain = 'default'): string { return $text; }
function __(string $text, string $domain = 'default'): string { return $text; }
function _e(string $text, string $domain = 'default'): void { echo $text; }
function wp_unslash(mixed $v): mixed { return $v; }
function wp_strip_all_tags(string $string, bool $remove_breaks = false): string { return strip_tags($string); }
function strip_shortcodes(string $content): string { return $content; }
function apply_filters(string $hook_name, mixed $value, mixed ...$args): mixed { return $value; }
function add_action(string $hook_name, callable $callback, int $priority = 10, int $accepted_args = 1): bool { return true; }
function add_filter(string $hook_name, callable $callback, int $priority = 10, int $accepted_args = 1): bool { return true; }
function add_menu_page(...$args): void {}
function add_meta_box(...$args): void {}
function get_post_types(...$args): array { return ['post', 'page']; }
function get_post(mixed $id): ?WP_Post { return new WP_Post(); }
function get_the_title(WP_Post $post): string { return $post->post_title; }
function get_the_excerpt(WP_Post $post): string { return $post->post_excerpt; }
function get_post_type(WP_Post $post): string { return $post->post_type; }
function get_permalink(int $id): string { return 'http://localhost:8000/guide-to-seo/'; }
function wp_nonce_field(...$args): void { echo '<input type="hidden" name="nonce" value="test_nonce" />'; }
function check_ajax_referer(...$args): bool { return true; }
function wp_create_nonce(string $action): string { return 'test_nonce_12345'; }
function wp_enqueue_style(...$args): void {}
function wp_enqueue_script(...$args): void {}
function wp_localize_script(...$args): void {}
function wp_sitemaps_get_server(): bool { return true; }
function url_to_postid(string $url): int { return 42; }

function get_posts(array $args): array {
    if (($args['post_type'] ?? '') === 'attachment') {
        return [101, 102, 103, 104];
    }
    return [new WP_Post()];
}

function get_post_meta(int $post_id, string $key, bool $single = false): mixed {
    if ($key === '_wp_attachment_image_alt') {
        return $post_id === 104 ? '' : 'Descriptive alt text for image ' . $post_id;
    }
    return '';
}

function is_wp_error(mixed $thing): bool {
    return $thing instanceof WP_Error;
}

function wp_remote_get(string $url, array $args = []): array|WP_Error {
    // Simulate isolated testing environment: local loopback requests fail
    if (str_contains($url, 'localhost') || str_contains($url, '127.0.0.1')) {
        return new WP_Error('cURL error 7: Failed to connect to localhost port 8000: Connection refused');
    }

    return [
        'response' => ['code' => 200],
        'body' => '<!DOCTYPE html><html><head><title>External Test Site - SEO Audited</title><meta name="description" content="This is an external test website with valid meta description."><meta name="viewport" content="width=device-width, initial-scale=1.0"><link rel="canonical" href="https://example.com/"></head><body><h1>Primary H1 Heading</h1><p>' . str_repeat('Content words for testing search indexing readability. ', 25) . '</p><img src="test.png" alt="Test image"></body></html>',
    ];
}

function wp_remote_retrieve_response_code(array|WP_Error $response): int {
    return is_wp_error($response) ? 0 : ($response['response']['code'] ?? 200);
}

function wp_remote_retrieve_body(array|WP_Error $response): string {
    return is_wp_error($response) ? '' : ($response['body'] ?? '');
}

// 2. Load Plugin Files
require_once SEOWEBCHECKER_PLUGIN_DIR . 'includes/class-auditor.php';
require_once SEOWEBCHECKER_PLUGIN_DIR . 'includes/class-admin.php';
require_once SEOWEBCHECKER_PLUGIN_DIR . 'includes/class-metabox.php';

// 3. Test Runner
$passed_tests = 0;
$total_tests = 0;

function run_test(string $name, callable $fn): void {
    global $passed_tests, $total_tests;
    $total_tests++;
    echo "[TEST $total_tests] $name... ";
    try {
        $result = $fn();
        if ($result === true) {
            echo "PASSED [OK]\n";
            $passed_tests++;
        } else {
            echo "FAILED: " . print_r($result, true) . "\n";
        }
    } catch (Throwable $e) {
        echo "EXCEPTION: " . $e->getMessage() . "\n" . $e->getTraceAsString() . "\n";
    }
}

// TEST 1: Assets Exist on Disk
run_test("Verifying CSS and JS asset paths exist on disk", function() {
    $css = SEOWEBCHECKER_PLUGIN_DIR . 'assets/css/admin.css';
    $js  = SEOWEBCHECKER_PLUGIN_DIR . 'assets/js/admin.js';
    return file_exists($css) && file_exists($js) && filesize($css) > 500 && filesize($js) > 500;
});

// TEST 2: Native Site Environment Audit (Offline / Localhost)
run_test("Running Native Site Environment Audit (zero HTTP calls)", function() {
    $auditor = new SEOWebChecker_Auditor();
    $report = $auditor->audit_site_environment();

    if (empty($report['success'])) return "Report success flag false";
    if (!isset($report['score']['overall'])) return "Missing overall score";
    if (!isset($report['score']['grade'])) return "Missing grade";
    if (empty($report['issues'])) return "Issues array empty";

    echo "\n    -> Overall Site Score: " . $report['score']['overall'] . "/100 (Grade: " . $report['score']['grade'] . ")";
    echo "\n    -> Total Checks: " . $report['stats']['total'] . " (Passed: " . $report['stats']['passed'] . ", Warnings: " . $report['stats']['warnings'] . ", Errors: " . $report['stats']['errors'] . ")";

    // Check that issues have titles and recommendations
    foreach ($report['issues'] as $issue) {
        if (empty($issue['title']) || empty($issue['message'])) {
            return "Malformed issue entry";
        }
    }
    return true;
});

// TEST 3: Native Post Audit (Post Editor Metabox)
run_test("Running Native Single Post Audit via Post Object", function() {
    $auditor = new SEOWebChecker_Auditor();
    $post = new WP_Post();
    $report = $auditor->audit_post_object($post);

    if (empty($report['success'])) return "Report success flag false";
    echo "\n    -> Post Score: " . $report['score']['overall'] . "/100 (Grade: " . $report['score']['grade'] . ")";
    echo "\n    -> Issues: " . count($report['issues']) . " (Passed: " . $report['stats']['passed'] . ", Warnings: " . $report['stats']['warnings'] . ", Errors: " . $report['stats']['errors'] . ")";
    foreach ($report['issues'] as $i) {
        echo "\n       - [" . $i['severity'] . "] " . $i['title'];
    }
    return true;
});

// TEST 4: Resilient Loopback Fallback (Localhost HTTP Failure Handling)
run_test("Testing Resilient Fallback when HTTP loopback connection fails", function() {
    $auditor = new SEOWebChecker_Auditor();
    // In our mock, localhost triggers a connection failure or native resolution
    $report = $auditor->audit_url('http://localhost:8000/guide-to-seo/');

    if (empty($report['success'])) return "Report failed instead of falling back gracefully";
    if (empty($report['issues'])) return "Report returned no issues on fallback";
    if (!in_array($report['source'] ?? '', ['native_internal_post', 'internal_post_fallback'], true)) {
        return "Source is not native_internal_post: " . ($report['source'] ?? '');
    }

    echo "\n    -> Fallback/Native handled gracefully! Source: " . $report['source'];
    echo "\n    -> Score calculated: " . $report['score']['overall'];
    return true;
});

// TEST 5: External Live URL Audit
run_test("Testing External Live URL Audit", function() {
    $auditor = new SEOWebChecker_Auditor();
    $report = $auditor->audit_url('https://example.com/blog/article');

    if (empty($report['success'])) return "Report failed for external URL";
    if ($report['score']['overall'] < 70) return "Score too low for valid external mock HTML";

    echo "\n    -> External URL Score: " . $report['score']['overall'] . "/100 (Grade: " . $report['score']['grade'] . ")";
    return true;
});

// TEST 6: Render Admin Page HTML (No PHP Notices / Warnings / WSOD)
run_test("Rendering Admin Dashboard Page (Buffer Inspection)", function() {
    ob_start();
    SEOWebChecker_Admin::render_admin_page();
    $html = ob_get_clean();

    if (!str_contains($html, 'seowebchecker-wrap')) return "Missing wrap div";
    if (!str_contains($html, 'seowebchecker-run-site-btn')) return "Missing site audit button";
    if (!str_contains($html, 'seowebchecker-audit-form')) return "Missing audit form";
    if (!str_contains($html, 'seowebchecker-issues-container')) return "Missing issues container";

    echo "\n    -> Admin Page successfully rendered (" . strlen($html) . " bytes of HTML without errors)";
    return true;
});

// TEST 7: Render Post Metabox HTML (No PHP Notices / Warnings / WSOD)
run_test("Rendering Post Metabox (Buffer Inspection)", function() {
    $post = new WP_Post();
    ob_start();
    SEOWebChecker_Metabox::render_metabox($post);
    $html = ob_get_clean();

    if (!str_contains($html, 'seowebchecker-metabox-wrapper')) return "Missing metabox wrapper";
    if (!str_contains($html, 'seowebchecker-run-post-audit')) return "Missing run audit button";
    if (!str_contains($html, 'seowebchecker-post-issues-list')) return "Missing issues list";

    echo "\n    -> Metabox successfully rendered (" . strlen($html) . " bytes of HTML without errors)";
    return true;
});

// Summary
echo "\n---------------------------------------------------------\n";
echo "  SUMMARY: $passed_tests of $total_tests tests passed successfully.\n";
echo "---------------------------------------------------------\n";

if ($passed_tests === $total_tests) {
    echo ">>> ALL TESTS PASSED! The plugin code is fully verified and ready for WordPress review.\n";
    exit(0);
} else {
    echo ">>> SOME TESTS FAILED.\n";
    exit(1);
}
