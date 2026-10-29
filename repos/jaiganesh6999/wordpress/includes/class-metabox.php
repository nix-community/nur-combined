<?php
/**
 * SEOWebChecker Post Editor Metabox Integration
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

final class SEOWebChecker_Metabox {

    public static function init(): void {
        add_action('add_meta_boxes', [self::class, 'register_metabox']);
        add_action('wp_ajax_seowebchecker_audit_post', [self::class, 'ajax_audit_post']);
    }

    public static function register_metabox(): void {
        $post_types = get_post_types(['public' => true], 'names');
        foreach ($post_types as $post_type) {
            add_meta_box(
                'seowebchecker_audit_metabox',
                __('SEOWebChecker: Live On-Page Scorecard', 'seowebchecker'),
                [self::class, 'render_metabox'],
                $post_type,
                'side',
                'high'
            );
        }
    }

    public static function render_metabox(WP_Post $post): void {
        wp_nonce_field('seowebchecker_metabox_nonce', 'seowebchecker_nonce');
        $permalink = get_permalink($post->ID);
        ?>
        <div id="seowebchecker-metabox-wrapper">
            <p class="description" style="margin-bottom: 10px;">
                <?php esc_html_e('Inspect technical SEO factors before publishing.', 'seowebchecker'); ?>
            </p>

            <div style="margin-bottom: 12px;">
                <button type="button" class="button button-primary" id="seowebchecker-run-post-audit" data-post-id="<?php echo esc_attr((string) $post->ID); ?>" data-url="<?php echo esc_url($permalink ?: ''); ?>" style="width: 100%; text-align: center;">
                    <span class="dashicons dashicons-search" style="vertical-align: text-top; font-size: 16px; width: 16px; height: 16px;"></span>
                    <?php esc_html_e('Analyze On-Page SEO', 'seowebchecker'); ?>
                </button>
                <div id="seowebchecker-metabox-spinner-wrap" style="display: none; text-align: center; margin-top: 8px;">
                    <span class="spinner is-active" id="seowebchecker-metabox-spinner" style="float: none; margin: 0 4px 0 0;"></span>
                    <span style="font-size: 11px; color: #646970;"><?php esc_html_e('Checking headings, meta, alt text...', 'seowebchecker'); ?></span>
                </div>
            </div>

            <div id="seowebchecker-metabox-results" style="display: none;">
                <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px; padding: 10px; background: #f0f6fc; border: 1px solid #c8d7e1; border-radius: 4px;">
                    <div>
                        <strong><?php esc_html_e('SEO Score:', 'seowebchecker'); ?></strong>
                        <span id="seowebchecker-post-score" style="font-size: 1.3em; font-weight: bold; margin-left: 4px;">--</span>/100
                    </div>
                    <div>
                        <span id="seowebchecker-post-grade" style="display: inline-block; padding: 2px 8px; border-radius: 4px; font-weight: bold; color: #fff; background: #2271b1;">-</span>
                    </div>
                </div>

                <ul id="seowebchecker-post-issues-list" style="margin: 0; padding: 0; list-style: none; font-size: 12px;">
                    <!-- Populated via JS -->
                </ul>
            </div>
        </div>
        <?php
    }

    public static function ajax_audit_post(): void {
        check_ajax_referer('seowebchecker_admin_nonce', 'nonce');

        if (!current_user_can('edit_posts')) {
            wp_send_json_error(__('Unauthorized permission level.', 'seowebchecker'), 403);
        }

        $post_id = isset($_POST['post_id']) ? (int) $_POST['post_id'] : 0;
        $post = get_post($post_id);

        if (!$post instanceof WP_Post) {
            wp_send_json_error(__('Invalid post ID provided.', 'seowebchecker'), 400);
        }

        $auditor = new SEOWebChecker_Auditor();
        $report = $auditor->audit_post_object($post);

        wp_send_json_success($report);
    }
}
