"""Interactive Local Frontend Web Dashboard for seowebchecker-seoaudit-sdk.
Run this script to launch a local web UI to test and interact with the SEO Auditor.
"""

import sys
import os
import json
import webbrowser
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs, urlparse

# Ensure local Python SDK is on sys.path
SDK_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "python")
if SDK_PATH not in sys.path:
    sys.path.insert(0, SDK_PATH)

from seowebchecker_seoaudit.auditor import SEOAuditor
from seowebchecker_seoaudit.formatters import format_markdown, format_html

PORT = int(os.environ.get("PORT", 5000))
HOST = os.environ.get("HOST", "0.0.0.0")

HTML_PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SEOWebChecker SDK — Local Interactive Test Dashboard</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    body { font-family: 'Plus Jakarta Sans', sans-serif; }
    code, pre { font-family: 'JetBrains Mono', monospace; }
  </style>
</head>
<body class="bg-slate-50 min-h-screen text-slate-800 antialiased">

  <!-- Top Navigation -->
  <header class="bg-white border-b border-slate-200 sticky top-0 z-30 shadow-sm">
    <div class="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between">
      <div class="flex items-center space-x-3">
        <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-indigo-600 to-violet-500 flex items-center justify-center text-white shadow-md shadow-indigo-200">
          <i class="fa-solid fa-chart-line text-lg"></i>
        </div>
        <div>
          <div class="flex items-center space-x-2">
            <span class="font-extrabold text-lg tracking-tight text-slate-900">SEOWebChecker</span>
            <span class="text-xs bg-indigo-100 text-indigo-700 font-semibold px-2 py-0.5 rounded-full">Local SDK Runner</span>
          </div>
          <p class="text-xs text-slate-500">Testing <code class="text-indigo-600 font-medium">seowebchecker-seoaudit-sdk</code> in real-time</p>
        </div>
      </div>
      <div class="flex items-center space-x-3">
        <a href="https://seowebchecker.com/" target="_blank" class="text-xs font-semibold text-slate-600 hover:text-indigo-600 transition flex items-center gap-1">
          <i class="fa-solid fa-arrow-up-right-from-square"></i> Official Site
        </a>
        <a href="https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk" target="_blank" class="text-xs bg-slate-900 text-white font-semibold px-3 py-1.5 rounded-lg hover:bg-slate-800 transition flex items-center gap-1.5">
          <i class="fa-brands fa-github"></i> GitHub Repo
        </a>
      </div>
    </div>
  </header>

  <!-- Main Container -->
  <main class="max-w-6xl mx-auto px-4 py-8">
    
    <!-- Hero / Input Card -->
    <div class="bg-white rounded-2xl border border-slate-200 p-6 md:p-8 shadow-sm mb-8">
      <div class="max-w-3xl">
        <h1 class="text-2xl md:text-3xl font-extrabold text-slate-900 tracking-tight mb-2">
          Test Your Python / Node / PHP SDK Engine
        </h1>
        <p class="text-slate-600 text-sm mb-6">
          Enter any live URL to run 50+ on-page, technical, social, and performance SEO checks directly through your local <code class="bg-slate-100 px-1.5 py-0.5 rounded text-indigo-600">SEOAuditor</code> class.
        </p>

        <!-- Audit Form -->
        <form id="auditForm" class="flex flex-col md:flex-row gap-3">
          <div class="relative flex-grow">
            <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
              <i class="fa-solid fa-globe"></i>
            </div>
            <input 
              type="url" 
              id="targetUrl" 
              name="url" 
              required
              placeholder="https://example.com"
              value="https://example.com"
              class="w-full pl-10 pr-4 py-3 bg-slate-50 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:bg-white focus:outline-none text-sm transition"
            />
          </div>
          <button 
            type="submit" 
            id="auditBtn"
            class="px-6 py-3 bg-indigo-600 hover:bg-indigo-700 active:scale-95 text-white font-bold rounded-xl shadow-md shadow-indigo-200 transition flex items-center justify-center gap-2 whitespace-nowrap text-sm"
          >
            <i class="fa-solid fa-magnifying-glass"></i>
            <span>Run SEO Audit</span>
          </button>
        </form>

        <!-- Quick Demo Presets -->
        <div class="mt-4 flex flex-wrap items-center gap-2 text-xs text-slate-500">
          <span class="font-medium text-slate-400">Try Quick Presets:</span>
          <button onclick="setAndRun('https://example.com')" class="px-2.5 py-1 bg-slate-100 hover:bg-slate-200 rounded-md transition">example.com</button>
          <button onclick="setAndRun('https://github.com')" class="px-2.5 py-1 bg-slate-100 hover:bg-slate-200 rounded-md transition">github.com</button>
          <button onclick="setAndRun('https://seowebchecker.com/')" class="px-2.5 py-1 bg-slate-100 hover:bg-slate-200 rounded-md transition">seowebchecker.com</button>
          <button onclick="setAndRun('https://news.ycombinator.com')" class="px-2.5 py-1 bg-slate-100 hover:bg-slate-200 rounded-md transition">news.ycombinator.com</button>
        </div>
      </div>
    </div>

    <!-- Loading State (Hidden by default) -->
    <div id="loadingCard" class="hidden bg-white rounded-2xl border border-slate-200 p-12 text-center shadow-sm mb-8">
      <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-indigo-50 text-indigo-600 mb-4 animate-spin text-2xl">
        <i class="fa-solid fa-spinner"></i>
      </div>
      <h3 class="text-lg font-bold text-slate-900 mb-1">Analyzing Website...</h3>
      <p id="loadingMsg" class="text-sm text-slate-500">Fetching document, evaluating meta tags, images, headings & Core Web Vitals...</p>
    </div>

    <!-- Error State -->
    <div id="errorCard" class="hidden bg-red-50 border border-red-200 rounded-2xl p-6 mb-8 text-red-800">
      <div class="flex items-start gap-3">
        <i class="fa-solid fa-circle-exclamation text-red-500 text-xl mt-0.5"></i>
        <div>
          <h4 class="font-bold text-sm">Audit Error</h4>
          <p id="errorMsg" class="text-sm mt-1 text-red-700"></p>
        </div>
      </div>
    </div>

    <!-- Results Section (Populated dynamically) -->
    <div id="resultsSection" class="hidden space-y-6">

      <!-- Executive Overview Card -->
      <div class="bg-white rounded-2xl border border-slate-200 p-6 md:p-8 shadow-sm">
        <div class="flex flex-col md:flex-row items-start md:items-center justify-between gap-6 pb-6 border-b border-slate-100">
          <div>
            <span class="text-xs font-semibold uppercase tracking-wider text-indigo-600">Audit Target</span>
            <h2 id="resUrl" class="text-xl md:text-2xl font-extrabold text-slate-900 break-all mt-0.5"></h2>
            <div class="flex items-center gap-3 text-xs text-slate-400 mt-1">
              <span id="resTime"><i class="fa-regular fa-clock"></i> </span>
              <span id="resLatency"><i class="fa-solid fa-bolt"></i> </span>
            </div>
          </div>

          <!-- Score Badges -->
          <div class="flex items-center gap-4">
            <div class="text-center px-5 py-3 rounded-2xl border-2" id="scoreBorder">
              <span id="resScore" class="block text-4xl font-extrabold leading-none"></span>
              <span class="text-[11px] font-bold uppercase tracking-wider text-slate-400 mt-1 block">Score / 100</span>
            </div>
            <div class="text-center px-5 py-3 rounded-2xl bg-slate-900 text-white min-w-[80px]">
              <span id="resGrade" class="block text-4xl font-extrabold leading-none text-emerald-400"></span>
              <span class="text-[11px] font-bold uppercase tracking-wider text-slate-400 mt-1 block">Grade</span>
            </div>
          </div>
        </div>

        <!-- Metric Counter Pills -->
        <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 pt-6">
          <div class="bg-emerald-50 border border-emerald-100 rounded-xl p-3.5 flex items-center gap-3">
            <div class="w-10 h-10 rounded-lg bg-emerald-500 text-white flex items-center justify-center font-bold text-lg">
              <i class="fa-solid fa-check"></i>
            </div>
            <div>
              <div id="cntPassed" class="text-xl font-extrabold text-emerald-900 leading-none">0</div>
              <div class="text-xs text-emerald-700 font-medium mt-0.5">Passed Checks</div>
            </div>
          </div>

          <div class="bg-amber-50 border border-amber-100 rounded-xl p-3.5 flex items-center gap-3">
            <div class="w-10 h-10 rounded-lg bg-amber-500 text-white flex items-center justify-center font-bold text-lg">
              <i class="fa-solid fa-triangle-exclamation"></i>
            </div>
            <div>
              <div id="cntWarnings" class="text-xl font-extrabold text-amber-900 leading-none">0</div>
              <div class="text-xs text-amber-700 font-medium mt-0.5">Warnings</div>
            </div>
          </div>

          <div class="bg-red-50 border border-red-100 rounded-xl p-3.5 flex items-center gap-3">
            <div class="w-10 h-10 rounded-lg bg-red-500 text-white flex items-center justify-center font-bold text-lg">
              <i class="fa-solid fa-xmark"></i>
            </div>
            <div>
              <div id="cntErrors" class="text-xl font-extrabold text-red-900 leading-none">0</div>
              <div class="text-xs text-red-700 font-medium mt-0.5">Critical Errors</div>
            </div>
          </div>

          <div class="bg-blue-50 border border-blue-100 rounded-xl p-3.5 flex items-center gap-3">
            <div class="w-10 h-10 rounded-lg bg-blue-500 text-white flex items-center justify-center font-bold text-lg">
              <i class="fa-solid fa-circle-info"></i>
            </div>
            <div>
              <div id="cntTotal" class="text-xl font-extrabold text-blue-900 leading-none">0</div>
              <div class="text-xs text-blue-700 font-medium mt-0.5">Total Evaluated</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Category Breakdown Grid -->
      <div class="bg-white rounded-2xl border border-slate-200 p-6 md:p-8 shadow-sm">
        <h3 class="text-lg font-bold text-slate-900 mb-4 flex items-center gap-2">
          <i class="fa-solid fa-layer-group text-indigo-600"></i> Category Breakdown
        </h3>
        <div id="categoryGrid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <!-- Populated by JS -->
        </div>
      </div>

      <!-- Key Page Elements Summary -->
      <div class="bg-white rounded-2xl border border-slate-200 p-6 md:p-8 shadow-sm">
        <h3 class="text-lg font-bold text-slate-900 mb-4 flex items-center gap-2">
          <i class="fa-solid fa-tags text-indigo-600"></i> Key Page Signals Extracted
        </h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm" id="signalsBox">
          <!-- Populated by JS -->
        </div>
      </div>

      <!-- Filterable Issues List -->
      <div class="bg-white rounded-2xl border border-slate-200 p-6 md:p-8 shadow-sm">
        <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6">
          <h3 class="text-lg font-bold text-slate-900 flex items-center gap-2">
            <i class="fa-solid fa-list-check text-indigo-600"></i> Audit Checks & Issues
          </h3>
          <div class="flex items-center gap-1 bg-slate-100 p-1 rounded-xl text-xs font-semibold">
            <button onclick="filterIssues('all')" id="btnTabAll" class="px-3 py-1.5 rounded-lg bg-white shadow-sm text-slate-900">All</button>
            <button onclick="filterIssues('error')" id="btnTabError" class="px-3 py-1.5 rounded-lg text-slate-600 hover:text-slate-900">Errors</button>
            <button onclick="filterIssues('warning')" id="btnTabWarning" class="px-3 py-1.5 rounded-lg text-slate-600 hover:text-slate-900">Warnings</button>
            <button onclick="filterIssues('pass')" id="btnTabPass" class="px-3 py-1.5 rounded-lg text-slate-600 hover:text-slate-900">Passed</button>
          </div>
        </div>
        <div id="issuesList" class="space-y-3">
          <!-- Populated by JS -->
        </div>
      </div>

      <!-- Raw JSON View (Accordion) -->
      <div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm">
        <details>
          <summary class="font-bold text-sm text-slate-700 cursor-pointer hover:text-indigo-600 flex items-center justify-between">
            <span><i class="fa-solid fa-code text-indigo-600 mr-2"></i> Inspect Raw SDK JSON Payload</span>
            <span class="text-xs text-slate-400">Click to expand</span>
          </summary>
          <pre id="rawJsonBox" class="mt-4 p-4 bg-slate-900 text-slate-100 rounded-xl text-xs overflow-x-auto max-h-96"></pre>
        </details>
      </div>

    </div>
  </main>

  <footer class="border-t border-slate-200 bg-white py-6 mt-12 text-center text-xs text-slate-500">
    Running locally with <span class="font-semibold text-slate-700">seowebchecker-seoaudit-sdk</span> • Official tool: <a href="https://seowebchecker.com/" target="_blank" class="text-indigo-600 font-bold hover:underline">SEOWebChecker.com</a>
  </footer>

  <script>
    let currentIssues = [];

    function setAndRun(url) {
      document.getElementById('targetUrl').value = url;
      runAudit(url);
    }

    document.getElementById('auditForm').addEventListener('submit', function(e) {
      e.preventDefault();
      const url = document.getElementById('targetUrl').value.trim();
      if (url) runAudit(url);
    });

    async function runAudit(url) {
      const loading = document.getElementById('loadingCard');
      const results = document.getElementById('resultsSection');
      const errorCard = document.getElementById('errorCard');
      const btn = document.getElementById('auditBtn');

      loading.classList.remove('hidden');
      results.classList.add('hidden');
      errorCard.classList.add('hidden');
      btn.disabled = true;
      btn.classList.add('opacity-50');

      try {
        const response = await fetch('/api/audit', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ url })
        });

        const data = await response.json();

        if (!response.ok || data.error) {
          throw new Error(data.error || 'Failed to complete audit');
        }

        renderResults(data);
      } catch (err) {
        errorCard.classList.remove('hidden');
        document.getElementById('errorMsg').textContent = err.message;
      } finally {
        loading.classList.add('hidden');
        btn.disabled = false;
        btn.classList.remove('opacity-50');
      }
    }

    function renderResults(data) {
      document.getElementById('resultsSection').classList.remove('hidden');

      // Overview
      document.getElementById('resUrl').textContent = data.url;
      document.getElementById('resTime').innerHTML = `<i class="fa-regular fa-clock"></i> ${new Date(data.timestamp).toLocaleTimeString()}`;
      document.getElementById('resLatency').innerHTML = `<i class="fa-solid fa-bolt"></i> ${data.performance.response_time_ms} ms response time`;

      const score = data.score.overall;
      const grade = data.score.grade;
      const scoreColor = score >= 85 ? '#10B981' : (score >= 70 ? '#F59E0B' : '#EF4444');

      document.getElementById('resScore').textContent = score;
      document.getElementById('resScore').style.color = scoreColor;
      document.getElementById('scoreBorder').style.borderColor = scoreColor;
      document.getElementById('resGrade').textContent = grade;

      // Stats
      document.getElementById('cntPassed').textContent = data.stats.passed;
      document.getElementById('cntWarnings').textContent = data.stats.warnings;
      document.getElementById('cntErrors').textContent = data.stats.errors;
      document.getElementById('cntTotal').textContent = data.stats.total_checks;

      // Categories
      const catGrid = document.getElementById('categoryGrid');
      catGrid.innerHTML = '';
      for (const [name, cat] of Object.entries(data.score.categories)) {
        const catColor = cat.score >= 85 ? 'bg-emerald-500' : (cat.score >= 70 ? 'bg-amber-500' : 'bg-red-500');
        catGrid.innerHTML += `
          <div class="p-4 bg-slate-50 border border-slate-200/80 rounded-xl">
            <div class="flex justify-between items-center mb-1.5">
              <span class="font-semibold text-slate-800 text-sm capitalize">${name}</span>
              <span class="font-extrabold text-slate-900 text-sm">${cat.score}/100</span>
            </div>
            <div class="w-full bg-slate-200 rounded-full h-2">
              <div class="h-2 rounded-full ${catColor}" style="width: ${cat.score}%"></div>
            </div>
            <div class="text-[11px] text-slate-500 mt-2">
              ${cat.passed_count} Pass • ${cat.warning_count} Warn • ${cat.error_count} Err
            </div>
          </div>
        `;
      }

      // Signals
      const signals = document.getElementById('signalsBox');
      signals.innerHTML = `
        <div class="p-3 bg-slate-50 rounded-xl"><strong>Title:</strong> <span class="text-slate-600">${escapeHtml(data.meta.title || '[None]')} (${data.meta.title_length} chars)</span></div>
        <div class="p-3 bg-slate-50 rounded-xl"><strong>Meta Description:</strong> <span class="text-slate-600">${escapeHtml(data.meta.description || '[None]')} (${data.meta.description_length} chars)</span></div>
        <div class="p-3 bg-slate-50 rounded-xl"><strong>Canonical URL:</strong> <span class="text-slate-600 break-all">${escapeHtml(data.meta.canonical || '[None]')}</span></div>
        <div class="p-3 bg-slate-50 rounded-xl"><strong>Word Count:</strong> <span class="text-slate-600">${data.content.word_count} words (~${data.content.reading_time_minutes} min read)</span></div>
        <div class="p-3 bg-slate-50 rounded-xl"><strong>Headings Hierarchy:</strong> <span class="text-slate-600">H1: ${data.content.h1_tags.length}, H2: ${data.content.h2_tags.length}, H3: ${data.content.h3_tags.length}</span></div>
        <div class="p-3 bg-slate-50 rounded-xl"><strong>Images Alt Quality:</strong> <span class="text-slate-600">${data.images.total_images} total (${data.images.missing_alt} missing alt)</span></div>
        <div class="p-3 bg-slate-50 rounded-xl"><strong>Technical & SSL:</strong> <span class="text-slate-600">HTTPS: ${data.technical.is_https ? 'Yes' : 'No'}, HSTS: ${data.technical.hsts_enabled ? 'Yes' : 'No'}</span></div>
        <div class="p-3 bg-slate-50 rounded-xl"><strong>Structured Data:</strong> <span class="text-slate-600">${data.schema.has_schema ? (data.schema.detected_types.join(', ') || 'Detected') : 'None'}</span></div>
      `;

      // Issues
      currentIssues = data.issues;
      filterIssues('all');

      // Raw JSON
      document.getElementById('rawJsonBox').textContent = JSON.stringify(data, null, 2);
    }

    function filterIssues(sev) {
      // Toggle button styles
      ['all', 'error', 'warning', 'pass'].forEach(tab => {
        const b = document.getElementById('btnTab' + tab.charAt(0).toUpperCase() + tab.slice(1));
        if (tab === sev) {
          b.className = "px-3 py-1.5 rounded-lg bg-white shadow-sm text-slate-900";
        } else {
          b.className = "px-3 py-1.5 rounded-lg text-slate-600 hover:text-slate-900";
        }
      });

      const list = document.getElementById('issuesList');
      list.innerHTML = '';

      const filtered = sev === 'all' ? currentIssues : currentIssues.filter(i => i.severity === sev);

      if (filtered.length === 0) {
        list.innerHTML = '<div class="text-center py-6 text-slate-400 text-sm">No checks in this category.</div>';
        return;
      }

      for (const item of filtered) {
        const badgeClasses = {
          'error': 'bg-red-100 text-red-700 border-red-200',
          'warning': 'bg-amber-100 text-amber-700 border-amber-200',
          'pass': 'bg-emerald-100 text-emerald-700 border-emerald-200',
          'notice': 'bg-blue-100 text-blue-700 border-blue-200',
        }[item.severity] || 'bg-slate-100 text-slate-700';

        const icon = {
          'error': '<i class="fa-solid fa-circle-xmark text-red-500"></i>',
          'warning': '<i class="fa-solid fa-triangle-exclamation text-amber-500"></i>',
          'pass': '<i class="fa-solid fa-circle-check text-emerald-500"></i>',
          'notice': '<i class="fa-solid fa-circle-info text-blue-500"></i>',
        }[item.severity] || '•';

        list.innerHTML += `
          <div class="border border-slate-200/80 rounded-xl p-4 bg-white hover:border-slate-300 transition">
            <div class="flex items-center justify-between gap-3">
              <div class="flex items-center gap-2">
                <span class="text-base">${icon}</span>
                <span class="font-bold text-slate-900 text-sm">${escapeHtml(item.title)}</span>
              </div>
              <span class="text-[10px] uppercase font-extrabold px-2 py-0.5 rounded-full border ${badgeClasses}">${item.severity}</span>
            </div>
            <p class="text-xs text-slate-600 mt-2 pl-6">${escapeHtml(item.message)}</p>
            ${item.severity !== 'pass' ? `
              <div class="mt-2.5 ml-6 text-xs bg-slate-50 border-l-2 border-indigo-500 p-2 text-slate-700 rounded-r">
                <strong>Fix Recommendation:</strong> ${escapeHtml(item.recommendation)}
              </div>
            ` : ''}
          </div>
        `;
      }
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
  </script>
</body>
</html>
"""


class DashboardRequestHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # Concise logging
        sys.stderr.write(f"[{self.log_date_time_string()}] {format % args}\n")

    def _send_cors_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Accept")

    def do_OPTIONS(self):
        self.send_response(204)
        self._send_cors_headers()
        self.end_headers()

    def do_GET(self):
        parsed_url = urlparse(self.path)
        params = parse_qs(parsed_url.query)
        target_url = params.get("url", ["https://seowebchecker.com/"])[0].strip()

        if parsed_url.path == "/" or parsed_url.path == "/index.html":
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(HTML_PAGE.encode("utf-8"))
            return

        if parsed_url.path == "/api/score":
            try:
                auditor = SEOAuditor(timeout=15)
                res = auditor.audit(target_url)
                payload = {
                    "url": res.url,
                    "score": res.score.overall,
                    "grade": res.score.grade,
                    "categories": {k: v.score for k, v in res.score.categories.items()},
                    "source": "https://seowebchecker.com/",
                }
                self.send_response(200)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps(payload, indent=2).encode("utf-8"))
            except Exception as e:
                self.send_response(400)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode("utf-8"))
            return

        if parsed_url.path == "/api/meta":
            try:
                auditor = SEOAuditor(timeout=15)
                res = auditor.audit(target_url)
                payload = {
                    "url": res.url,
                    "title": res.meta.title if res.meta else None,
                    "title_length": res.meta.title_length if res.meta else 0,
                    "description": res.meta.description if res.meta else None,
                    "description_length": res.meta.description_length if res.meta else 0,
                    "canonical": res.meta.canonical if res.meta else None,
                    "robots": res.meta.robots if res.meta else None,
                    "open_graph": {
                        "og_title": res.social.og_title if res.social else None,
                        "og_description": res.social.og_description if res.social else None,
                        "og_image": res.social.og_image if res.social else None,
                    } if res.social else {},
                    "source": "https://seowebchecker.com/",
                }
                self.send_response(200)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps(payload, indent=2).encode("utf-8"))
            except Exception as e:
                self.send_response(400)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode("utf-8"))
            return

        if parsed_url.path == "/api/vitals":
            try:
                auditor = SEOAuditor(timeout=15)
                res = auditor.audit(target_url)
                payload = {
                    "url": res.url,
                    "response_time_ms": res.performance.response_time_ms if res.performance else 0,
                    "page_size_kb": res.performance.page_size_kb if res.performance else 0,
                    "diagnostics": {
                        "ttfb": "Good" if (res.performance and res.performance.response_time_ms < 600) else "Needs Improvement",
                        "status": "Healthy",
                    },
                    "source": "https://seowebchecker.com/",
                }
                self.send_response(200)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps(payload, indent=2).encode("utf-8"))
            except Exception as e:
                self.send_response(400)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode("utf-8"))
            return

        if parsed_url.path == "/api/images":
            try:
                auditor = SEOAuditor(timeout=15)
                res = auditor.audit(target_url)
                payload = {
                    "url": res.url,
                    "total_images": res.images.total_images if res.images else 0,
                    "missing_alt": res.images.missing_alt if res.images else 0,
                    "modern_formats": res.images.modern_formats_count if res.images else 0,
                    "source": "https://seowebchecker.com/",
                }
                self.send_response(200)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps(payload, indent=2).encode("utf-8"))
            except Exception as e:
                self.send_response(400)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode("utf-8"))
            return

        self.send_response(404)
        self._send_cors_headers()
        self.end_headers()

    def do_POST(self):
        parsed_url = urlparse(self.path)
        if parsed_url.path == "/api/audit":
            content_length = int(self.headers.get("Content-Length", 0))
            post_body = self.rfile.read(content_length).decode("utf-8")

            try:
                data = json.loads(post_body)
                url = data.get("url", "").strip()

                if not url:
                    raise ValueError("URL is required")

                auditor = SEOAuditor(timeout=15)
                result = auditor.audit(url)

                payload = result.to_dict()

                self.send_response(200)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps(payload, indent=2).encode("utf-8"))

            except Exception as e:
                self.send_response(400)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode("utf-8"))
        else:
            self.send_response(404)
            self._send_cors_headers()
            self.end_headers()


def start_server():
    server_address = (HOST, PORT)
    httpd = HTTPServer(server_address, DashboardRequestHandler)
    url = f"http://{HOST}:{PORT}"

    print("=" * 65)
    print(f"  SEOWebChecker SDK Interactive Local Frontend")
    print(f"  Running at: {url}")
    print("=" * 65)
    print("Press Ctrl+C to stop the server\n")

    if os.environ.get("HEADLESS", "false").lower() != "true" and "FLY_APP_NAME" not in os.environ:
        try:
            webbrowser.open(f"http://localhost:{PORT}")
        except Exception:
            pass

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping local frontend server...")
        httpd.server_close()


if __name__ == "__main__":
    start_server()
