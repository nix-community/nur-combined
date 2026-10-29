<?php
/**
 * SEOWebChecker Admin Dashboard Page & Controller
 * Compatible with PHP 8.2
 *
 * Official Website: https://seowebchecker.com/
 *
 * @package SEOWebChecker
 */

declare(strict_types=1);

if (!defined('ABSPATH')) {
    exit;
}

final class SEOWebChecker_Admin {

    public static function init(): void {
        add_action('admin_menu', [self::class, 'register_admin_menu']);
        add_action('admin_enqueue_scripts', [self::class, 'enqueue_assets']);
        add_action('wp_ajax_seowebchecker_run_audit', [self::class, 'ajax_run_audit']);
        add_action('wp_ajax_seowebchecker_run_site_audit', [self::class, 'ajax_run_site_audit']);
        add_action('admin_bar_menu', [self::class, 'add_admin_bar_item'], 100);
    }

    public static function register_admin_menu(): void {
        add_menu_page(
            __('SEOWebChecker: Technical SEO Audit', 'seowebchecker'),
            __('SEO Web Checker', 'seowebchecker'),
            'manage_options',
            'seowebchecker',
            [self::class, 'render_admin_page'],
            'dashicons-chart-area',
            95
        );
    }

    public static function enqueue_assets(string $hook_suffix): void {
        if ($hook_suffix !== 'toplevel_page_seowebchecker' && !in_array($hook_suffix, ['post.php', 'post-new.php'], true)) {
            return;
        }

        wp_enqueue_style(
            'seowebchecker-admin-css',
            SEOWEBCHECKER_PLUGIN_URL . 'assets/css/admin.css',
            [],
            SEOWEBCHECKER_VERSION
        );

        wp_enqueue_script(
            'seowebchecker-admin-js',
            SEOWEBCHECKER_PLUGIN_URL . 'assets/js/admin.js',
            ['jquery'],
            SEOWEBCHECKER_VERSION,
            true
        );

        wp_localize_script('seowebchecker-admin-js', 'seowebchecker_vars', [
            'ajax_url' => admin_url('admin-ajax.php'),
            'nonce'    => wp_create_nonce('seowebchecker_admin_nonce'),
            'home_url' => home_url('/'),
            'i18n'     => [
                'auditing'       => __('Analyzing technical SEO factors...', 'seowebchecker'),
                'run_audit'      => __('Run Technical SEO Audit', 'seowebchecker'),
                'run_site_audit' => __('Run Site-Wide Audit', 'seowebchecker'),
                'error_msg'      => __('Audit request encountered an issue. Displaying local diagnostics.', 'seowebchecker'),
                'copied'         => __('Copied report to clipboard!', 'seowebchecker'),
            ],
        ]);
    }

    public static function add_admin_bar_item(WP_Admin_Bar $wp_admin_bar): void {
        if (!current_user_can('manage_options') || is_admin()) {
            return;
        }

        global $wp;
        $current_url = home_url(add_query_arg([], $wp->request ?? ''));

        $wp_admin_bar->add_node([
            'id'    => 'seowebchecker-bar-node',
            'title' => '<span class="ab-icon dashicons-chart-area" style="top:2px;"></span> ' . esc_html__('Audit This Page (SEO)', 'seowebchecker'),
            'href'  => admin_url('admin.php?page=seowebchecker&audit_url=' . urlencode($current_url)),
        ]);
    }

    public static function render_admin_page(): void {
        if (!current_user_can('manage_options')) {
            wp_die(esc_html__('You do not have sufficient permissions to access this page.', 'seowebchecker'));
        }

        $default_url = isset($_GET['audit_url']) ? esc_url_raw(wp_unslash($_GET['audit_url'])) : home_url('/');

        // Query up to 10 published posts/pages for quick one-click dropdown audit
        $recent_posts = get_posts([
            'post_type'      => ['post', 'page'],
            'post_status'    => 'publish',
            'posts_per_page' => 10,
            'orderby'        => 'date',
            'order'          => 'DESC',
        ]);
        ?>
        <div class="wrap seowebchecker-wrap">
            <header class="seowebchecker-header">
                <div class="seowebchecker-header-left">
                    <h1>
                        <span class="dashicons dashicons-chart-area"></span>
                        <?php esc_html_e('SEOWebChecker: Technical SEO & Site Health Audit', 'seowebchecker'); ?>
                    </h1>
                    <p class="description">
                        <?php esc_html_e('Complete on-page diagnostics, indexing validations, heading hierarchy, image accessibility, and technical SEO health checks.', 'seowebchecker'); ?>
                    </p>
                </div>
            </header>

            <!-- Navigation Tabs -->
            <nav class="nav-tab-wrapper seowebchecker-nav-tabs">
                <a href="#tab-site" class="nav-tab nav-tab-active" id="seowebchecker-tab-site-link">
                    <span class="dashicons dashicons-admin-site-alt3"></span>
                    <?php esc_html_e('Site Health & Technical SEO', 'seowebchecker'); ?>
                </a>
                <a href="#tab-page" class="nav-tab" id="seowebchecker-tab-page-link">
                    <span class="dashicons dashicons-media-document"></span>
                    <?php esc_html_e('Page & URL Analyzer', 'seowebchecker'); ?>
                </a>
            </nav>

            <!-- Panel 1: Site Health Audit -->
            <div id="seowebchecker-panel-site" class="seowebchecker-tab-panel">
                <div class="seowebchecker-card seowebchecker-action-card">
                    <div class="seowebchecker-card-flex">
                        <div>
                            <h2><?php esc_html_e('WordPress Technical SEO & Indexing Health', 'seowebchecker'); ?></h2>
                            <p class="description">
                                <?php esc_html_e('Audits your search engine visibility settings, permalink structures, core XML sitemaps, image alt coverage in media library, and content depth across published entries.', 'seowebchecker'); ?>
                            </p>
                        </div>
                        <div>
                            <button type="button" id="seowebchecker-run-site-btn" class="button button-primary button-hero">
                                <span class="dashicons dashicons-update" style="vertical-align: middle;"></span>
                                <span id="seowebchecker-site-btn-text"><?php esc_html_e('Run Complete Site Audit', 'seowebchecker'); ?></span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Panel 2: Single Page / URL Analyzer -->
            <div id="seowebchecker-panel-page" class="seowebchecker-tab-panel" style="display: none;">
                <div class="seowebchecker-card seowebchecker-search-card">
                    <form id="seowebchecker-audit-form">
                        <label for="seowebchecker-url-input"><strong><?php esc_html_e('Target Page or Webpage URL:', 'seowebchecker'); ?></strong></label>
                        <div class="seowebchecker-input-group">
                            <input type="url" id="seowebchecker-url-input" class="regular-text" value="<?php echo esc_attr($default_url); ?>" required placeholder="https://example.com" />
                            <button type="submit" id="seowebchecker-submit-btn" class="button button-primary">
                                <span class="dashicons dashicons-search" style="vertical-align: middle;"></span>
                                <span id="seowebchecker-btn-text"><?php esc_html_e('Analyze Page', 'seowebchecker'); ?></span>
                            </button>
                        </div>

                        <?php if (!empty($recent_posts)): ?>
                            <div class="seowebchecker-quick-select" style="margin-top: 14px;">
                                <label for="seowebchecker-post-select"><small><?php esc_html_e('Or quickly choose a published post/page to audit:', 'seowebchecker'); ?></small></label>
                                <select id="seowebchecker-post-select" style="max-width: 400px; margin-left: 8px;">
                                    <option value=""><?php esc_html_e('-- Select a Post or Page --', 'seowebchecker'); ?></option>
                                    <?php foreach ($recent_posts as $p): ?>
                                        <option value="<?php echo esc_url(get_permalink($p->ID)); ?>" data-post-id="<?php echo esc_attr((string) $p->ID); ?>">
                                            <?php echo esc_html(get_the_title($p) ?: '(No title #' . $p->ID . ')'); ?> (<?php echo esc_html(get_post_type($p)); ?>)
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        <?php endif; ?>
                    </form>
                </div>
            </div>

            <!-- Loading Spinner State -->
            <div id="seowebchecker-loading" style="display: none;" class="seowebchecker-card seowebchecker-loading-card">
                <span class="spinner is-active" style="float: none; width: 32px; height: 32px; margin-bottom: 12px;"></span>
                <h3 id="seowebchecker-loading-title"><?php esc_html_e('Analyzing technical SEO factors...', 'seowebchecker'); ?></h3>
                <p><?php esc_html_e('Inspecting metadata, headings, content word counts, image accessibility, and indexing parameters.', 'seowebchecker'); ?></p>
            </div>

            <!-- Error / Notice Notification -->
            <div id="seowebchecker-notice" style="display: none;" class="notice notice-info">
                <p id="seowebchecker-notice-text"></p>
            </div>

            <!-- Results Dashboard Container -->
            <div id="seowebchecker-results" style="display: none;">
                <!-- Overview Stats Grid -->
                <div class="seowebchecker-grid">
                    <div class="seowebchecker-card seowebchecker-score-card">
                        <div class="score-circle-wrapper" id="seowebchecker-circle-wrapper">
                            <div class="score-circle" id="seowebchecker-score-val">--</div>
                            <div class="score-grade-badge" id="seowebchecker-grade-val">-</div>
                        </div>
                        <h3><?php esc_html_e('Overall SEO Score', 'seowebchecker'); ?></h3>
                        <p id="seowebchecker-target-url" class="score-url"></p>
                    </div>

                    <div class="seowebchecker-card seowebchecker-stat-card">
                        <h4><?php esc_html_e('Passed Checks', 'seowebchecker'); ?></h4>
                        <div class="stat-number text-success" id="seowebchecker-stat-passed">0</div>
                        <p class="description"><?php esc_html_e('Optimized factors', 'seowebchecker'); ?></p>
                    </div>

                    <div class="seowebchecker-card seowebchecker-stat-card">
                        <h4><?php esc_html_e('Warnings', 'seowebchecker'); ?></h4>
                        <div class="stat-number text-warning" id="seowebchecker-stat-warnings">0</div>
                        <p class="description"><?php esc_html_e('Action recommended', 'seowebchecker'); ?></p>
                    </div>

                    <div class="seowebchecker-card seowebchecker-stat-card">
                        <h4><?php esc_html_e('Errors', 'seowebchecker'); ?></h4>
                        <div class="stat-number text-danger" id="seowebchecker-stat-errors">0</div>
                        <p class="description"><?php esc_html_e('Critical issues', 'seowebchecker'); ?></p>
                    </div>
                </div>

                <!-- Export & Filter Bar -->
                <div class="seowebchecker-toolbar">
                    <div class="seowebchecker-filter-buttons">
                        <button type="button" class="button button-small seowebchecker-filter-btn is-active" data-filter="all">
                            <?php esc_html_e('All Checks', 'seowebchecker'); ?>
                        </button>
                        <button type="button" class="button button-small seowebchecker-filter-btn" data-filter="error">
                            <?php esc_html_e('Errors Only', 'seowebchecker'); ?>
                        </button>
                        <button type="button" class="button button-small seowebchecker-filter-btn" data-filter="warning">
                            <?php esc_html_e('Warnings Only', 'seowebchecker'); ?>
                        </button>
                        <button type="button" class="button button-small seowebchecker-filter-btn" data-filter="pass">
                            <?php esc_html_e('Passed Checks', 'seowebchecker'); ?>
                        </button>
                    </div>

                    <div class="seowebchecker-actions-bar">
                        <button type="button" class="button" id="seowebchecker-copy-md">
                            <span class="dashicons dashicons-clipboard"></span> <?php esc_html_e('Copy Markdown', 'seowebchecker'); ?>
                        </button>
                        <button type="button" class="button" id="seowebchecker-download-json">
                            <span class="dashicons dashicons-download"></span> <?php esc_html_e('Export JSON', 'seowebchecker'); ?>
                        </button>
                    </div>
                </div>

                <!-- Detailed Issues Breakdown -->
                <div class="seowebchecker-card">
                    <h2><?php esc_html_e('Detailed Diagnostic Findings & In-Dashboard Remediation', 'seowebchecker'); ?></h2>
                    <div id="seowebchecker-issues-container">
                        <!-- Populated by admin.js -->
                    </div>
                </div>
            </div>

            <footer class="seowebchecker-footer" style="margin-top: 30px; padding-top: 15px; border-top: 1px solid #dcdcde; color: #646970; font-size: 12px; display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <span><?php esc_html_e('SEOWebChecker Technical SEO Engine v1.0.0', 'seowebchecker'); ?></span>
                </div>
                <div>
                    <a href="https://seowebchecker.com/" target="_blank" rel="noopener noreferrer" style="color: #646970; text-decoration: none;">
                        <?php esc_html_e('SEOWebChecker.com', 'seowebchecker'); ?>
                    </a>
                </div>
            </footer>
        </div>
        <?php
    }

    public static function ajax_run_site_audit(): void {
        check_ajax_referer('seowebchecker_admin_nonce', 'nonce');

        if (!current_user_can('manage_options')) {
            wp_send_json_error(__('Unauthorized permission level.', 'seowebchecker'), 403);
        }

        $auditor = new SEOWebChecker_Auditor();
        $report = $auditor->audit_site_environment();

        wp_send_json_success($report);
    }

    public static function ajax_run_audit(): void {
        check_ajax_referer('seowebchecker_admin_nonce', 'nonce');

        if (!current_user_can('manage_options')) {
            wp_send_json_error(__('Unauthorized permission level.', 'seowebchecker'), 403);
        }

        $post_id = isset($_POST['post_id']) ? (int) $_POST['post_id'] : 0;
        $auditor = new SEOWebChecker_Auditor();

        if ($post_id > 0) {
            $post = get_post($post_id);
            if ($post instanceof WP_Post) {
                $report = $auditor->audit_post_object($post);
                wp_send_json_success($report);
            }
        }

        $url = isset($_POST['url']) ? esc_url_raw(wp_unslash($_POST['url'])) : '';
        if (empty($url)) {
            $url = home_url('/');
        }

        $report = $auditor->audit_url($url);
        wp_send_json_success($report);
    }
}
