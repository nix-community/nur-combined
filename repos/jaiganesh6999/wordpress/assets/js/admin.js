/**
 * SEOWebChecker WordPress Admin JavaScript
 * Complete native dashboard controller with resilient error handling
 */

/* global jQuery, seowebchecker_vars */
(function ($) {
  'use strict';

  let latestAuditReport = null;
  let activeFilter = 'all';

  $(document).ready(function () {
    initTabs();
    initFilterButtons();
    initSiteAudit();
    initPageAudit();
    initMetabox();
    initExports();

    // Auto-run site audit on page load if on the main plugin page
    if ($('#seowebchecker-panel-site').length > 0) {
      runSiteAudit();
    }
  });

  // 1. Navigation Tabs
  function initTabs() {
    $('#seowebchecker-tab-site-link').on('click', function (e) {
      e.preventDefault();
      $(this).addClass('nav-tab-active').siblings().removeClass('nav-tab-active');
      $('#seowebchecker-panel-site').show();
      $('#seowebchecker-panel-page').hide();
    });

    $('#seowebchecker-tab-page-link').on('click', function (e) {
      e.preventDefault();
      $(this).addClass('nav-tab-active').siblings().removeClass('nav-tab-active');
      $('#seowebchecker-panel-page').show();
      $('#seowebchecker-panel-site').hide();
    });

    // Quick select dropdown updates the URL input
    $('#seowebchecker-post-select').on('change', function () {
      const selectedVal = $(this).val();
      if (selectedVal) {
        $('#seowebchecker-url-input').val(selectedVal);
      }
    });
  }

  // 2. Site Audit Runner
  function initSiteAudit() {
    $('#seowebchecker-run-site-btn').on('click', function (e) {
      e.preventDefault();
      runSiteAudit();
    });
  }

  function runSiteAudit() {
    const btn = $('#seowebchecker-run-site-btn');
    btn.prop('disabled', true);

    $('#seowebchecker-notice').hide();
    $('#seowebchecker-loading-title').text(seowebchecker_vars.i18n.auditing);
    $('#seowebchecker-loading').show();

    $.ajax({
      url: seowebchecker_vars.ajax_url,
      type: 'POST',
      dataType: 'json',
      data: {
        action: 'seowebchecker_run_site_audit',
        nonce: seowebchecker_vars.nonce,
      },
      success: function (res) {
        btn.prop('disabled', false);
        $('#seowebchecker-loading').hide();

        if (res && res.success && res.data) {
          latestAuditReport = res.data;
          renderDashboardResults(res.data);
        } else {
          showNotice(res.data || seowebchecker_vars.i18n.error_msg, 'warning');
        }
      },
      error: function (xhr) {
        btn.prop('disabled', false);
        $('#seowebchecker-loading').hide();
        const msg = (xhr.responseJSON && xhr.responseJSON.data) ? xhr.responseJSON.data : seowebchecker_vars.i18n.error_msg;
        showNotice(msg, 'error');
      },
    });
  }

  // 3. Single Page / URL Audit Runner
  function initPageAudit() {
    $('#seowebchecker-audit-form').on('submit', function (e) {
      e.preventDefault();

      const targetUrl = $('#seowebchecker-url-input').val().trim();
      const selectedPostId = $('#seowebchecker-post-select').find(':selected').data('post-id') || 0;

      if (!targetUrl && !selectedPostId) {
        return;
      }

      const submitBtn = $('#seowebchecker-submit-btn');
      submitBtn.prop('disabled', true);

      $('#seowebchecker-notice').hide();
      $('#seowebchecker-loading-title').text(seowebchecker_vars.i18n.auditing);
      $('#seowebchecker-loading').show();

      $.ajax({
        url: seowebchecker_vars.ajax_url,
        type: 'POST',
        dataType: 'json',
        data: {
          action: 'seowebchecker_run_audit',
          nonce: seowebchecker_vars.nonce,
          url: targetUrl,
          post_id: selectedPostId,
        },
        success: function (res) {
          submitBtn.prop('disabled', false);
          $('#seowebchecker-loading').hide();

          if (res && res.success && res.data) {
            latestAuditReport = res.data;
            renderDashboardResults(res.data);
          } else {
            showNotice(res.data || seowebchecker_vars.i18n.error_msg, 'warning');
          }
        },
        error: function (xhr) {
          submitBtn.prop('disabled', false);
          $('#seowebchecker-loading').hide();
          const msg = (xhr.responseJSON && xhr.responseJSON.data) ? xhr.responseJSON.data : seowebchecker_vars.i18n.error_msg;
          showNotice(msg, 'error');
        },
      });
    });
  }

  function showNotice(msg, type) {
    const notice = $('#seowebchecker-notice');
    notice.removeClass('notice-info notice-warning notice-error').addClass('notice-' + (type || 'info'));
    $('#seowebchecker-notice-text').text(msg);
    notice.show();
  }

  // 4. Render Dashboard Results
  function renderDashboardResults(report) {
    if (!report) return;

    const score = report.score ? report.score.overall : 0;
    const grade = report.score ? report.score.grade : 'F';

    $('#seowebchecker-score-val').text(score);
    $('#seowebchecker-grade-val').text(grade);
    $('#seowebchecker-target-url').text(report.url || seowebchecker_vars.home_url);

    // Color score circle
    const circle = $('#seowebchecker-circle-wrapper');
    const gradeBadge = $('#seowebchecker-grade-val');
    let themeColor = '#d63638';
    if (score >= 90) themeColor = '#008a20';
    else if (score >= 80) themeColor = '#2271b1';
    else if (score >= 70) themeColor = '#d68100';

    circle.css('border-color', themeColor);
    gradeBadge.css('background', themeColor);

    // Stats
    const stats = report.stats || {};
    $('#seowebchecker-stat-passed').text(stats.passed || 0);
    $('#seowebchecker-stat-warnings').text(stats.warnings || 0);
    $('#seowebchecker-stat-errors').text(stats.errors || 0);

    // Optional environment notice
    if (report.notice) {
      showNotice(report.notice, 'info');
    }

    // Render Issues List
    renderIssuesList(report.issues || []);

    $('#seowebchecker-results').slideDown(200);
  }

  function renderIssuesList(issues) {
    const container = $('#seowebchecker-issues-container');
    container.empty();

    if (!issues || issues.length === 0) {
      container.html('<p style="padding: 16px; color: #50575e;">No issues detected for this audit.</p>');
      return;
    }

    let renderedCount = 0;
    issues.forEach(function (issue) {
      const severity = issue.severity || 'pass';

      // Apply active filter
      if (activeFilter !== 'all' && severity !== activeFilter) {
        return;
      }

      renderedCount++;
      const actionBtn = (issue.action_url && issue.action_label)
        ? `<a href="${escapeHtml(issue.action_url)}" class="button button-small seowebchecker-issue-action-btn">${escapeHtml(issue.action_label)} &rarr;</a>`
        : '';

      const html = `
        <div class="seowebchecker-issue-item severity-${severity}">
          <div class="issue-header">
            <span class="issue-title">${escapeHtml(issue.title)}</span>
            <span class="issue-badge badge-${severity}">${severity}</span>
          </div>
          <div class="issue-message">${escapeHtml(issue.message)}</div>
          ${issue.recommendation ? `<div class="issue-recommendation"><strong>Recommendation:</strong> ${escapeHtml(issue.recommendation)}</div>` : ''}
          ${actionBtn ? `<div class="issue-actions" style="margin-top: 8px;">${actionBtn}</div>` : ''}
        </div>
      `;
      container.append(html);
    });

    if (renderedCount === 0) {
      container.html(`<p style="padding: 16px; color: #50575e;">No checks found matching filter "${escapeHtml(activeFilter)}".</p>`);
    }
  }

  // 5. Issue Filters
  function initFilterButtons() {
    $('.seowebchecker-filter-btn').on('click', function () {
      $('.seowebchecker-filter-btn').removeClass('is-active');
      $(this).addClass('is-active');
      activeFilter = $(this).data('filter') || 'all';

      if (latestAuditReport) {
        renderIssuesList(latestAuditReport.issues || []);
      }
    });
  }

  // 6. Post Editor Metabox Runner
  function initMetabox() {
    $('#seowebchecker-run-post-audit').on('click', function () {
      const btn = $(this);
      const postId = btn.data('post-id');
      const spinnerWrap = $('#seowebchecker-metabox-spinner-wrap');

      btn.prop('disabled', true);
      spinnerWrap.show();

      $.ajax({
        url: seowebchecker_vars.ajax_url,
        type: 'POST',
        dataType: 'json',
        data: {
          action: 'seowebchecker_audit_post',
          nonce: seowebchecker_vars.nonce,
          post_id: postId,
        },
        success: function (res) {
          btn.prop('disabled', false);
          spinnerWrap.hide();

          if (res && res.success && res.data) {
            renderMetaboxResults(res.data);
          } else {
            alert((res && res.data) ? res.data : seowebchecker_vars.i18n.error_msg);
          }
        },
        error: function () {
          btn.prop('disabled', false);
          spinnerWrap.hide();
          alert(seowebchecker_vars.i18n.error_msg);
        },
      });
    });
  }

  function renderMetaboxResults(report) {
    const score = report.score ? report.score.overall : 0;
    const grade = report.score ? report.score.grade : 'F';

    $('#seowebchecker-post-score').text(score);
    const gradeEl = $('#seowebchecker-post-grade');
    gradeEl.text(grade);

    let color = '#d63638';
    if (score >= 90) color = '#008a20';
    else if (score >= 80) color = '#2271b1';
    else if (score >= 70) color = '#d68100';
    gradeEl.css('background', color);

    const list = $('#seowebchecker-post-issues-list');
    list.empty();

    if (report.issues && report.issues.length > 0) {
      report.issues.slice(0, 6).forEach(function (issue) {
        const icon = issue.severity === 'pass' ? '✅' : (issue.severity === 'warning' ? '⚠️' : '❌');
        list.append(`<li style="margin-bottom: 6px; line-height: 1.4;">${icon} <strong>${escapeHtml(issue.title)}</strong></li>`);
      });
    }

    $('#seowebchecker-metabox-results').slideDown(150);
  }

  // 7. Export Buttons
  function initExports() {
    $('#seowebchecker-copy-md').on('click', function () {
      if (!latestAuditReport) return;
      const md = generateMarkdown(latestAuditReport);
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(md).then(function () {
          alert(seowebchecker_vars.i18n.copied);
        });
      } else {
        const temp = $('<textarea>');
        $('body').append(temp);
        temp.val(md).select();
        document.execCommand('copy');
        temp.remove();
        alert(seowebchecker_vars.i18n.copied);
      }
    });

    $('#seowebchecker-download-json').on('click', function () {
      if (!latestAuditReport) return;
      const dataStr = 'data:text/json;charset=utf-8,' + encodeURIComponent(JSON.stringify(latestAuditReport, null, 2));
      const dlAnchorElem = document.createElement('a');
      dlAnchorElem.setAttribute('href', dataStr);
      dlAnchorElem.setAttribute('download', 'seowebchecker-audit-' + Date.now() + '.json');
      dlAnchorElem.click();
    });
  }

  function generateMarkdown(r) {
    let md = `# SEO Audit Report: ${r.url || 'Site Health'}\n`;
    md += `**Score**: ${r.score ? r.score.overall : '--'}/100 (Grade: ${r.score ? r.score.grade : '-'})\n`;
    if (r.stats) {
      md += `**Passed**: ${r.stats.passed} | **Warnings**: ${r.stats.warnings} | **Errors**: ${r.stats.errors}\n\n`;
    }
    md += `## Findings & Recommendations\n\n`;
    if (r.issues) {
      r.issues.forEach(function (i) {
        md += `- [${(i.severity || 'info').toUpperCase()}] **${i.title}**: ${i.message}\n`;
        if (i.recommendation) {
          md += `  *Recommendation*: ${i.recommendation}\n`;
        }
      });
    }
    md += `\n---\n*Report generated via SEOWebChecker WordPress Plugin*\n`;
    return md;
  }

  function escapeHtml(str) {
    if (!str) return '';
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

})(jQuery);
