<?php
/**
 * Plugin Name: SEOWebChecker
 * Description: Automated on-page technical SEO audits, meta tag validations, heading structure inspections, image accessibility, and Core Web Vitals checks inside your WordPress dashboard.
 * Version: 1.0.0
 * Requires at least: 5.8
 * Requires PHP: 8.0
 * Author: SEOWebChecker
 * Author URI: https://seowebchecker.com/
 * License: GPL-2.0-or-later
 * License URI: https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain: seowebchecker
 * Domain Path: /languages
 */

declare(strict_types=1);

if (!defined('ABSPATH')) {
    exit;
}

define('SEOWEBCHECKER_VERSION', '1.0.0');
define('SEOWEBCHECKER_PLUGIN_DIR', plugin_dir_path(__FILE__));
define('SEOWEBCHECKER_PLUGIN_URL', plugin_dir_url(__FILE__));

// Require Core Modules
require_once SEOWEBCHECKER_PLUGIN_DIR . 'includes/class-auditor.php';
require_once SEOWEBCHECKER_PLUGIN_DIR . 'includes/class-admin.php';
require_once SEOWEBCHECKER_PLUGIN_DIR . 'includes/class-metabox.php';

// Bootstrap Plugin
add_action('plugins_loaded', static function (): void {
    load_plugin_textdomain('seowebchecker', false, dirname(plugin_basename(__FILE__)) . '/languages');

    if (is_admin()) {
        SEOWebChecker_Admin::init();
        SEOWebChecker_Metabox::init();
    }
});

// Add settings link on Plugins page
add_filter('plugin_action_links_' . plugin_basename(__FILE__), static function (array $links): array {
    $settings_link = sprintf(
        '<a href="%s">%s</a>',
        esc_url(admin_url('admin.php?page=seowebchecker')),
        esc_html__('Run SEO Audit', 'seowebchecker')
    );
    array_unshift($links, $settings_link);
    return $links;
});
