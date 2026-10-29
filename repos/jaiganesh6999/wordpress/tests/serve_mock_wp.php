<?php
/**
 * Interactive Local Browser Testing Server for SEOWebChecker Plugin
 *
 * How to run:
 * & "C:\tools\php82\php.exe" -S localhost:8080 wordpress/tests/serve_mock_wp.php
 * Then open: http://localhost:8080/ in your web browser.
 */

declare(strict_types=1);

error_reporting(E_ALL);
ini_set('display_errors', '1');

// Handle static assets (.css, .js)
$request_uri = $_SERVER['REQUEST_URI'] ?? '/';
$path = parse_url($request_uri, PHP_URL_PATH);

if (str_starts_with($path, '/assets/')) {
    $file = dirname(__DIR__) . $path;
    if (file_exists($file)) {
        if (str_ends_with($file, '.css')) {
            header('Content-Type: text/css');
        } elseif (str_ends_with($file, '.js')) {
            header('Content-Type: application/javascript');
        }
        readfile($file);
        exit;
    }
}

// 1. Mock WordPress Core
define('ABSPATH', __DIR__ . '/../../');
define('SEOWEBCHECKER_VERSION', '1.0.0');
define('SEOWEBCHECKER_PLUGIN_DIR', dirname(__DIR__) . '/');
define('SEOWEBCHECKER_PLUGIN_URL', '/');

class WP_Post {
    public int $ID = 42;
    public string $post_title = 'The Definitive Guide to Technical SEO & Core Web Vitals';
    public string $post_content = '<h2>Introduction to Search Engine Optimization</h2><p>Technical SEO is the foundation of any successful digital strategy. Optimizing website architecture, heading structures, image alt attributes, and metadata ensures that search engines can easily crawl, index, and understand your content.</p><h2>Heading Structure and Readability</h2><p>Proper H1 and H2 tags establish semantic context. Content should be comprehensive, actionable, and structured for user accessibility. Always include clear meta descriptions and mobile responsive viewport configurations for optimal user experience across all devices.</p><img src="https://example.com/guide.jpg" alt="SEO Guide Infographic" /><p>Regular auditing catches regressions before they impact organic rankings.</p>';
    public string $post_excerpt = 'Comprehensive guide covering technical SEO audits, meta tags, heading structures, and Core Web Vitals.';
    public string $post_type = 'post';
    public string $post_status = 'publish';
}

class WP_Admin_Bar {
    public function add_node(array $args): void {}
}

class WP_Error {
    private string $message;
    public function __construct(string $message = 'Connection error') {
        $this->message = $message;
    }
    public function get_error_message(): string {
        return $this->message;
    }
}

$GLOBALS['wp_options'] = [
    'blog_public' => '1',
    'permalink_structure' => '/%postname%/',
];

function is_admin(): bool { return true; }
function is_ssl(): bool { return false; }
function current_time(string $type): string { return date('Y-m-d H:i:s'); }
function home_url(string $path = ''): string { return 'http://localhost:8080' . $path; }
function site_url(string $path = ''): string { return 'http://localhost:8080' . $path; }
function admin_url(string $path = ''): string { return '/admin-ajax.php'; }
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
function add_action(...$args): bool { return true; }
function add_filter(...$args): bool { return true; }
function add_menu_page(...$args): void {}
function add_meta_box(...$args): void {}
function get_post_types(...$args): array { return ['post', 'page']; }
function get_post(mixed $id): ?WP_Post { return new WP_Post(); }
function get_the_title(WP_Post $post): string { return $post->post_title; }
function get_the_excerpt(WP_Post $post): string { return $post->post_excerpt; }
function get_post_type(WP_Post $post): string { return $post->post_type; }
function get_permalink(int $id): string { return 'http://localhost:8080/sample-post/'; }
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
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_USERAGENT, 'SEOWebChecker-WP/1.0 (+https://seowebchecker.com/)');
    $body = curl_exec($ch);
    $code = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $err = curl_error($ch);
    curl_close($ch);

    if ($body === false || !empty($err)) {
        return new WP_Error($err ?: 'Connection failed');
    }

    return [
        'response' => ['code' => $code],
        'body'     => (string) $body,
    ];
}

function wp_remote_retrieve_response_code(array|WP_Error $response): int {
    return is_wp_error($response) ? 0 : ($response['response']['code'] ?? 200);
}

function wp_remote_retrieve_body(array|WP_Error $response): string {
    return is_wp_error($response) ? '' : ($response['body'] ?? '');
}

function wp_send_json_success(mixed $data = null): void {
    header('Content-Type: application/json; charset=UTF-8');
    echo json_encode(['success' => true, 'data' => $data]);
    exit;
}

function wp_send_json_error(mixed $data = null, int $status_code = null): void {
    header('Content-Type: application/json; charset=UTF-8');
    echo json_encode(['success' => false, 'data' => $data]);
    exit;
}

require_once SEOWEBCHECKER_PLUGIN_DIR . 'includes/class-auditor.php';
require_once SEOWEBCHECKER_PLUGIN_DIR . 'includes/class-admin.php';
require_once SEOWEBCHECKER_PLUGIN_DIR . 'includes/class-metabox.php';

// Handle AJAX Endpoints
if (str_starts_with($path, '/admin-ajax.php')) {
    $action = $_POST['action'] ?? ($_GET['action'] ?? '');
    if ($action === 'seowebchecker_run_site_audit') {
        SEOWebChecker_Admin::ajax_run_site_audit();
    } elseif ($action === 'seowebchecker_run_audit') {
        SEOWebChecker_Admin::ajax_run_audit();
    } elseif ($action === 'seowebchecker_audit_post') {
        SEOWebChecker_Metabox::ajax_audit_post();
    } else {
        wp_send_json_error('Unknown action');
    }
    exit;
}

// Render Complete WordPress Dashboard UI Simulation
header('Content-Type: text/html; charset=UTF-8');
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SEOWebChecker &lsaquo; WordPress Admin Simulation</title>
    <!-- WordPress Core Dashicons & Admin CSS Simulation -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/dashicons/0.9.0/css/dashicons.min.css">
    <style>
        body {
            margin: 0;
            padding: 0;
            background: #f0f0f1;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen-Sans, Ubuntu, Cantarell, "Helvetica Neue", sans-serif;
            color: #3c434a;
            font-size: 13px;
            line-height: 1.4em;
        }
        #wpadminbar {
            height: 32px;
            background: #1d2327;
            color: #c3c4c7;
            display: flex;
            align-items: center;
            padding: 0 16px;
            font-size: 13px;
        }
        #wpadminbar .ab-item { color: #f0f0f1; text-decoration: none; display: flex; align-items: center; gap: 6px; }
        .wp-layout {
            display: flex;
            min-height: calc(100vh - 32px);
        }
        .wp-sidebar {
            width: 160px;
            background: #1d2327;
            color: #c3c4c7;
            padding-top: 10px;
            flex-shrink: 0;
        }
        .wp-sidebar a {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            color: #c3c4c7;
            text-decoration: none;
            font-size: 13px;
        }
        .wp-sidebar a.current {
            background: #2271b1;
            color: #fff;
            font-weight: 600;
        }
        .wp-sidebar a:hover:not(.current) {
            background: #131619;
            color: #72aee6;
        }
        .wp-content {
            flex: 1;
            padding: 10px 20px;
            max-width: 1200px;
        }
        /* WordPress Core UI helpers */
        .button {
            display: inline-block;
            text-decoration: none;
            font-size: 13px;
            line-height: 2.15384615;
            min-height: 30px;
            margin: 0;
            padding: 0 10px;
            cursor: pointer;
            border-width: 1px;
            border-style: solid;
            -webkit-appearance: none;
            border-radius: 3px;
            white-space: nowrap;
            box-sizing: border-box;
            color: #2271b1;
            border-color: #2271b1;
            background: #f6f7f7;
            vertical-align: top;
        }
        .button:hover { background: #f0f0f1; border-color: #0a4b78; color: #0a4b78; }
        .button-primary {
            background: #2271b1;
            border-color: #2271b1;
            color: #fff;
        }
        .button-primary:hover { background: #135e96; border-color: #135e96; color: #fff; }
        .button-hero {
            font-size: 14px;
            height: 46px;
            line-height: 44px;
            padding: 0 24px;
        }
        .button-small {
            min-height: 26px;
            line-height: 24px;
            font-size: 11px;
            padding: 0 8px;
        }
        .nav-tab-wrapper {
            border-bottom: 1px solid #c3c4c7;
            margin: 0 0 16px;
            padding-top: 9px;
            padding-bottom: 0;
            line-height: inherit;
        }
        .nav-tab {
            border: 1px solid #c3c4c7;
            border-bottom: none;
            background: #dcdcde;
            color: #50575e;
            padding: 6px 12px;
            font-size: 14px;
            line-height: 1.71428571;
            text-decoration: none;
            margin-left: 0.5em;
            display: inline-block;
        }
        .nav-tab-active {
            background: #f0f0f1;
            border-bottom: 1px solid #f0f0f1;
            color: #1d2327;
            margin-bottom: -1px;
        }
        .notice {
            background: #fff;
            border: 1px solid #c3c4c7;
            border-left-width: 4px;
            box-shadow: 0 1px 1px rgba(0,0,0,.04);
            margin: 5px 0 15px;
            padding: 1px 12px;
        }
        .notice-info { border-left-color: #72aee6; }
        .notice-warning { border-left-color: #dba617; }
        .notice-error { border-left-color: #d63638; }
        .spinner {
            background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ccircle cx='50' cy='50' fill='none' stroke='%232271b1' stroke-width='8' r='35' stroke-dasharray='164.93361431346415 56.97787143782138' transform='rotate(170 50 50)'%3E%3CanimateTransform attributeName='transform' type='rotate' repeatCount='indefinite' dur='1s' values='0 50 50;360 50 50' keyTimes='0;1'/%3E%3C/circle%3E%3C/svg%3E") no-repeat;
            background-size: 20px 20px;
            display: inline-block;
            vertical-align: middle;
            opacity: 0.7;
            width: 20px;
            height: 20px;
            margin: 4px 10px 0;
        }
        .spinner.is-active { opacity: 1; }
        .regular-text {
            width: 25em;
            padding: 0 8px;
            line-height: 2;
            min-height: 30px;
            border: 1px solid #8c8f94;
            border-radius: 4px;
        }
    </style>
    <!-- Plugin Styles -->
    <link rel="stylesheet" href="/assets/css/admin.css">
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script>
        var seowebchecker_vars = {
            ajax_url: '/admin-ajax.php',
            nonce: 'test_nonce_12345',
            home_url: 'http://localhost:8080/',
            i18n: {
                auditing: 'Analyzing technical SEO factors...',
                run_audit: 'Run Technical SEO Audit',
                run_site_audit: 'Run Site-Wide Audit',
                error_msg: 'Audit request encountered an issue. Displaying local diagnostics.',
                copied: 'Copied report to clipboard!'
            }
        };
    </script>
</head>
<body>
    <div id="wpadminbar">
        <a href="#" class="ab-item">
            <span class="dashicons dashicons-wordpress" style="font-size:20px;width:20px;height:20px;"></span>
            <span>WordPress 6.6</span>
        </a>
    </div>

    <div class="wp-layout">
        <div class="wp-sidebar">
            <a href="#"><span class="dashicons dashicons-dashboard"></span> Dashboard</a>
            <a href="#"><span class="dashicons dashicons-admin-post"></span> Posts</a>
            <a href="#"><span class="dashicons dashicons-admin-media"></span> Media</a>
            <a href="#" class="current"><span class="dashicons dashicons-chart-area"></span> SEO Web Checker</a>
            <a href="#"><span class="dashicons dashicons-admin-settings"></span> Settings</a>
        </div>
        <div class="wp-content">
            <?php SEOWebChecker_Admin::render_admin_page(); ?>
        </div>
    </div>

    <!-- Plugin JavaScript -->
    <script src="/assets/js/admin.js"></script>
</body>
</html>
