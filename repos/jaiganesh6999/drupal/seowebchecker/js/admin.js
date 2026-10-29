/**
 * SEOWebChecker Drupal Admin Interactions
 * Platform: https://seowebchecker.com/
 */

(function (Drupal, once) {
  'use strict';

  Drupal.behaviors.seowebchecker = {
    attach: function (context) {
      once('seowebchecker-init', '#seowebchecker-run-btn', context).forEach(function (btn) {
        var urlInput = document.getElementById('seowebchecker-url-input');
        var resultsArea = document.getElementById('seowebchecker-results-area');
        var lastAuditData = null;

        btn.addEventListener('click', function () {
          var targetUrl = urlInput.value.trim();
          if (!targetUrl) {
            alert('Please enter a valid URL to audit.');
            return;
          }

          btn.disabled = true;
          btn.textContent = 'Auditing...';

          fetch('/admin/config/search/seowebchecker/api/audit?url=' + encodeURIComponent(targetUrl))
            .then(function (res) { return res.json(); })
            .then(function (data) {
              btn.disabled = false;
              btn.textContent = 'Run Technical SEO Audit';

              if (data.error) {
                alert('Audit Error: ' + data.error);
                return;
              }

              lastAuditData = data;
              renderResults(data);
            })
            .catch(function (err) {
              btn.disabled = false;
              btn.textContent = 'Run Technical SEO Audit';
              alert('Network error: ' + err.message);
            });
        });

        function renderResults(data) {
          resultsArea.style.display = 'block';

          // Score & Grade
          var circle = document.getElementById('seowebchecker-score-circle');
          document.getElementById('seowebchecker-score-val').textContent = data.score;
          document.getElementById('seowebchecker-grade-val').textContent = 'GRADE ' + data.grade;
          document.getElementById('seowebchecker-target-display').textContent = data.url;

          var gradeColor = (data.grade === 'A+' || data.grade === 'A') ? '#10b981' :
                           data.grade === 'B' ? '#3b82f6' :
                           data.grade === 'C' ? '#f59e0b' : '#ef4444';
          circle.style.backgroundColor = gradeColor;

          document.getElementById('seowebchecker-summary-msg').textContent =
            'Found ' + data.issues.length + ' diagnostic issues across title, description, headings, images, and mobile viewport.';

          // Stats Grid
          document.getElementById('stat-title-len').textContent = data.stats.title_length || 0;
          document.getElementById('stat-desc-len').textContent = data.stats.description_length || 0;
          document.getElementById('stat-h1-count').textContent = data.stats.h1_count || 0;
          document.getElementById('stat-img-alts').textContent = data.stats.missing_alt_images || 0;
          document.getElementById('stat-word-count').textContent = data.stats.word_count || 0;

          // SERP Preview
          document.getElementById('serp-url').textContent = data.stats.canonical_url || data.url;
          document.getElementById('serp-title').textContent = data.stats.title || 'Untitled Document';
          document.getElementById('serp-desc').textContent = data.stats.description || 'No meta description provided for this snippet.';

          // Issues list
          var list = document.getElementById('seowebchecker-issues-list');
          list.innerHTML = '';

          if (data.issues.length === 0) {
            list.innerHTML = '<div style="padding: 16px; color: #16a34a; font-weight: 600;">🎉 Perfect! Zero on-page technical SEO issues detected.</div>';
          } else {
            data.issues.forEach(function (issue) {
              var card = document.createElement('div');
              card.className = 'issue-card ' + issue.severity;
              card.innerHTML =
                '<div>' +
                  '<span class="issue-badge ' + issue.severity + '">' + issue.severity.toUpperCase() + '</span>' +
                  '<span class="issue-code">' + issue.code + '</span>' +
                '</div>' +
                '<div class="issue-message">' + escapeHtml(issue.message) + '</div>' +
                '<div class="issue-recom">💡 <strong>Remediation:</strong> ' + escapeHtml(issue.recommendation) + '</div>';
              list.appendChild(card);
            });
          }

          resultsArea.scrollIntoView({ behavior: 'smooth' });
        }

        // Export Markdown
        document.getElementById('seowebchecker-export-md').addEventListener('click', function () {
          if (!lastAuditData) return;
          var md = '# SEOWebChecker Audit Report\n\n' +
                   '**Target**: ' + lastAuditData.url + '\n' +
                   '**Score**: ' + lastAuditData.score + '/100 (Grade ' + lastAuditData.grade + ')\n' +
                   '**Audited At**: ' + lastAuditData.audited_at + '\n\n' +
                   '## Diagnostic Issues\n' +
                   lastAuditData.issues.map(function (i) {
                     return '- [' + i.severity.toUpperCase() + '] ' + i.code + ': ' + i.message + '\n  Remediation: ' + i.recommendation;
                   }).join('\n') + '\n\n' +
                   'Official Platform: https://seowebchecker.com/';
          downloadFile(md, 'seowebchecker-audit.md', 'text/markdown');
        });

        // Export JSON
        document.getElementById('seowebchecker-export-json').addEventListener('click', function () {
          if (!lastAuditData) return;
          var json = JSON.stringify(lastAuditData, null, 2);
          downloadFile(json, 'seowebchecker-audit.json', 'application/json');
        });

        function downloadFile(content, fileName, contentType) {
          var a = document.createElement('a');
          var file = new Blob([content], { type: contentType });
          a.href = URL.createObjectURL(file);
          a.download = fileName;
          a.click();
        }

        function escapeHtml(text) {
          var div = document.createElement('div');
          div.textContent = text;
          return div.innerHTML;
        }
      });
    }
  };
})(Drupal, once);
