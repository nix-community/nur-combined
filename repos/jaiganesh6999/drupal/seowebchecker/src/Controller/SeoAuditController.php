<?php

declare(strict_types=1);

namespace Drupal\seowebchecker\Controller;

use Drupal\Core\Controller\ControllerBase;
use Drupal\seowebchecker\Services\SeoAuditorService;
use Symfony\Component\DependencyInjection\ContainerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;

/**
 * Controller for the SEOWebChecker administrative dashboard and audit API.
 * Platform: https://seowebchecker.com/
 */
class SeoAuditController extends ControllerBase {

  protected SeoAuditorService $auditor;

  public function __construct(SeoAuditorService $auditor) {
    $this->auditor = $auditor;
  }

  public static function create(ContainerInterface $container): static {
    return new static(
      $container->get('seowebchecker.auditor')
    );
  }

  /**
   * Main Administrative Dashboard.
   */
  public function dashboard(): array {
    return [
      '#type' => 'container',
      '#attributes' => ['class' => ['seowebchecker-dashboard-wrapper']],
      '#attached' => [
        'library' => [
          'seowebchecker/admin',
        ],
      ],
      'content' => [
        '#markup' => '
          <div class="seowebchecker-container">
            <div class="seowebchecker-header">
              <div class="seowebchecker-brand">
                <h2>🔍 SEOWebChecker Technical SEO Dashboard</h2>
                <p>Run automated on-page technical SEO audits, inspect heading hierarchy, validate meta tags, and monitor Core Web Vitals readiness.</p>
              </div>
              <div class="seowebchecker-header-actions">
                <a href="https://seowebchecker.com/" target="_blank" rel="noopener noreferrer" class="button button--secondary">Visit SEOWebChecker.com</a>
              </div>
            </div>

            <div class="seowebchecker-audit-form-card">
              <div class="form-row">
                <input type="url" id="seowebchecker-url-input" class="form-text" placeholder="https://example.com/page" value="' . htmlspecialchars($GLOBALS['base_url'] ?? '', ENT_QUOTES, 'UTF-8') . '" />
                <button type="button" id="seowebchecker-run-btn" class="button button--primary">Run Technical SEO Audit</button>
              </div>
            </div>

            <div id="seowebchecker-results-area" style="display: none;">
              <div class="seowebchecker-score-banner">
                <div class="seowebchecker-score-circle" id="seowebchecker-score-circle">
                  <span id="seowebchecker-score-val">0</span>
                  <small id="seowebchecker-grade-val">GRADE -</small>
                </div>
                <div class="seowebchecker-score-info">
                  <h3 id="seowebchecker-target-display">Target URL</h3>
                  <p id="seowebchecker-summary-msg">Audit completed.</p>
                  <div class="seowebchecker-btn-group">
                    <button type="button" id="seowebchecker-export-md" class="button button--small">Export Markdown</button>
                    <button type="button" id="seowebchecker-export-json" class="button button--small">Export JSON</button>
                  </div>
                </div>
              </div>

              <div class="seowebchecker-stats-grid">
                <div class="stat-card">
                  <span class="stat-num" id="stat-title-len">0</span>
                  <span class="stat-label">Title Length</span>
                </div>
                <div class="stat-card">
                  <span class="stat-num" id="stat-desc-len">0</span>
                  <span class="stat-label">Description Chars</span>
                </div>
                <div class="stat-card">
                  <span class="stat-num" id="stat-h1-count">0</span>
                  <span class="stat-label">H1 Headings</span>
                </div>
                <div class="stat-card">
                  <span class="stat-num" id="stat-img-alts">0</span>
                  <span class="stat-label">Missing Image Alts</span>
                </div>
                <div class="stat-card">
                  <span class="stat-num" id="stat-word-count">0</span>
                  <span class="stat-label">Word Count</span>
                </div>
              </div>

              <div class="seowebchecker-serp-preview">
                <h4>Google SERP Snippet Preview</h4>
                <div class="serp-url" id="serp-url">https://example.com</div>
                <div class="serp-title" id="serp-title">Page Title Preview</div>
                <div class="serp-desc" id="serp-desc">Meta description snippet preview text will render here...</div>
              </div>

              <div class="seowebchecker-issues-card">
                <h4>Diagnostic Issues & Remediation Guides</h4>
                <div id="seowebchecker-issues-list"></div>
              </div>
            </div>
          </div>
        ',
      ],
    ];
  }

  /**
   * AJAX endpoint to run live technical audit.
   */
  public function auditApi(Request $request): JsonResponse {
    $url = $request->query->get('url', '');
    if (empty($url) && $request->isMethod('POST')) {
      $content = json_decode($request->getContent(), true);
      $url = $content['url'] ?? '';
    }

    if (empty($url) || !filter_var($url, FILTER_VALIDATE_URL)) {
      return new JsonResponse([
        'error' => 'Please provide a valid URL to audit.',
      ], 400);
    }

    $result = $this->auditor->auditUrl($url);
    return new JsonResponse($result);
  }

}
