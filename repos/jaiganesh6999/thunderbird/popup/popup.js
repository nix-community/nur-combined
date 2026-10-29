/**
 * SEOWebChecker - Technical SEO & HTML Analyzer for Mozilla Thunderbird
 * Compatible with Thunderbird MailExtension API
 */

// Tab Navigation
const tabButtons = {
  current: document.getElementById('tabAnalyzeCurrent'),
  custom: document.getElementById('tabCustomHtml'),
  url: document.getElementById('tabUrlInspect')
};

const tabPanes = {
  current: document.getElementById('sectionCurrent'),
  custom: document.getElementById('sectionCustom'),
  url: document.getElementById('sectionUrl')
};

function switchTab(selectedKey) {
  Object.keys(tabButtons).forEach(key => {
    if (key === selectedKey) {
      tabButtons[key].classList.add('active');
      tabPanes[key].classList.add('active');
    } else {
      tabButtons[key].classList.remove('active');
      tabPanes[key].classList.remove('active');
    }
  });
}

tabButtons.current.addEventListener('click', () => switchTab('current'));
tabButtons.custom.addEventListener('click', () => switchTab('custom'));
tabButtons.url.addEventListener('click', () => switchTab('url'));

// HTML Audit Engine
function auditHtml(htmlString, sourceUrl = '') {
  const parser = new DOMParser();
  const doc = parser.parseFromString(htmlString, 'text/html');

  const diagnostics = [];
  let score = 100;

  // 1. Title Check
  const title = doc.querySelector('title') ? doc.querySelector('title').textContent.trim() : '';
  if (!title) {
    score -= 15;
    diagnostics.push({ status: 'fail', name: 'Document Title', msg: 'Missing <title> tag.' });
  } else if (title.length < 10 || title.length > 60) {
    score -= 5;
    diagnostics.push({ status: 'warn', name: 'Document Title', msg: `Title length (${title.length} chars) is outside optimal 10-60 character range.` });
  } else {
    diagnostics.push({ status: 'pass', name: 'Document Title', msg: `Optimal title: "${title}".` });
  }

  // 2. Meta Description
  const metaDesc = doc.querySelector('meta[name="description"]');
  const descContent = metaDesc ? metaDesc.getAttribute('content') : '';
  if (!descContent) {
    score -= 15;
    diagnostics.push({ status: 'fail', name: 'Meta Description', msg: 'Missing meta description tag.' });
  } else if (descContent.length < 50 || descContent.length > 160) {
    score -= 5;
    diagnostics.push({ status: 'warn', name: 'Meta Description', msg: `Description length (${descContent.length} chars) outside 50-160 range.` });
  } else {
    diagnostics.push({ status: 'pass', name: 'Meta Description', msg: 'Meta description configured cleanly.' });
  }

  // 3. H1 Headings
  const h1s = doc.querySelectorAll('h1');
  if (h1s.length === 0) {
    score -= 15;
    diagnostics.push({ status: 'fail', name: 'H1 Structure', msg: 'No <h1> heading found.' });
  } else if (h1s.length > 1) {
    score -= 10;
    diagnostics.push({ status: 'warn', name: 'H1 Structure', msg: `Found ${h1s.length} <h1> tags. Multiple H1 tags can dilute primary topic.` });
  } else {
    diagnostics.push({ status: 'pass', name: 'H1 Structure', msg: `Single distinct <h1>: "${h1s[0].textContent.trim()}".` });
  }

  // 4. Image Alt Attributes
  const images = doc.querySelectorAll('img');
  let missingAlt = 0;
  images.forEach(img => {
    if (!img.hasAttribute('alt') || img.getAttribute('alt').trim() === '') {
      missingAlt++;
    }
  });

  if (images.length > 0) {
    if (missingAlt > 0) {
      score -= Math.min(20, missingAlt * 5);
      diagnostics.push({ status: 'fail', name: 'Image Accessibility & Alt Tags', msg: `${missingAlt} of ${images.length} images are missing descriptive alt text.` });
    } else {
      diagnostics.push({ status: 'pass', name: 'Image Accessibility & Alt Tags', msg: `All ${images.length} images contain alt attributes.` });
    }
  }

  // 5. Canonical Link
  const canonical = doc.querySelector('link[rel="canonical"]');
  if (!canonical || !canonical.getAttribute('href')) {
    score -= 10;
    diagnostics.push({ status: 'warn', name: 'Canonical Tag', msg: 'No canonical URL defined to prevent content duplication.' });
  } else {
    diagnostics.push({ status: 'pass', name: 'Canonical Tag', msg: `Canonical defined: ${canonical.getAttribute('href')}` });
  }

  // 6. Open Graph Tags
  const ogTitle = doc.querySelector('meta[property="og:title"]');
  const ogImage = doc.querySelector('meta[property="og:image"]');
  if (ogTitle && ogImage) {
    diagnostics.push({ status: 'pass', name: 'Social Open Graph', msg: 'Open Graph title and image tags present.' });
  } else {
    score -= 5;
    diagnostics.push({ status: 'warn', name: 'Social Open Graph', msg: 'Incomplete Open Graph social preview metadata.' });
  }

  // 7. Viewport
  const viewport = doc.querySelector('meta[name="viewport"]');
  if (viewport) {
    diagnostics.push({ status: 'pass', name: 'Mobile Viewport', msg: 'Mobile viewport configured properly.' });
  } else {
    score -= 10;
    diagnostics.push({ status: 'warn', name: 'Mobile Viewport', msg: 'Missing responsive mobile viewport tag.' });
  }

  // Render
  renderResults(Math.max(0, score), diagnostics);
}

function renderResults(score, diagnostics) {
  const resultsContainer = document.getElementById('resultsSection');
  const scoreEl = document.getElementById('overallScore');
  const listEl = document.getElementById('diagnosticsList');

  resultsContainer.classList.remove('hidden');
  scoreEl.textContent = `${score}/100`;

  if (score >= 80) {
    scoreEl.style.color = '#10b981';
  } else if (score >= 60) {
    scoreEl.style.color = '#f59e0b';
  } else {
    scoreEl.style.color = '#ef4444';
  }

  listEl.textContent = '';
  diagnostics.forEach(item => {
    const card = document.createElement('div');
    card.className = `diag-item ${item.status}`;
    
    const titleEl = document.createElement('div');
    titleEl.className = 'diag-title';
    titleEl.textContent = item.name;

    const msgEl = document.createElement('div');
    msgEl.className = 'diag-msg';
    msgEl.textContent = item.msg;

    card.appendChild(titleEl);
    card.appendChild(msgEl);
    listEl.appendChild(card);
  });
}

// Action: Audit Custom HTML
document.getElementById('btnAuditCustom').addEventListener('click', () => {
  const content = document.getElementById('customHtmlInput').value;
  if (!content.trim()) {
    alert('Please enter or paste HTML code to analyze.');
    return;
  }
  auditHtml(content);
});

// Action: Audit URL
document.getElementById('btnAuditUrl').addEventListener('click', async () => {
  const url = document.getElementById('urlInput').value.trim();
  if (!url) {
    alert('Please specify a URL.');
    return;
  }

  const btn = document.getElementById('btnAuditUrl');
  btn.disabled = true;
  btn.textContent = 'Auditing...';

  try {
    const res = await fetch(url);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const text = await res.text();
    auditHtml(text, url);
  } catch (err) {
    alert('Unable to fetch URL directly (CORS or network error). Analyzing provided URL syntax instead.');
    auditHtml(`<!DOCTYPE html><html><head><title>${url}</title><link rel="canonical" href="${url}"/></head><body><h1>Audited Target: ${url}</h1></body></html>`, url);
  } finally {
    btn.disabled = false;
    btn.textContent = 'Fetch & Audit URL';
  }
});

// Action: Audit Currently Open Thunderbird Message
document.getElementById('btnAuditCurrent').addEventListener('click', async () => {
  try {
    if (typeof browser !== 'undefined' && browser.messageDisplay && browser.messageDisplay.getDisplayedMessage) {
      const msg = await browser.messageDisplay.getDisplayedMessage();
      if (!msg) {
        alert('No email message currently selected in Thunderbird.');
        return;
      }
      
      const fullMessage = await browser.messages.getFull(msg.id);
      let bodyHtml = '';
      
      // Parse message parts for HTML body
      function extractHtml(part) {
        if (part.contentType && part.contentType.toLowerCase() === 'text/html' && part.body) {
          return part.body;
        }
        if (part.parts && part.parts.length > 0) {
          for (const sub of part.parts) {
            const found = extractHtml(sub);
            if (found) return found;
          }
        }
        return '';
      }

      bodyHtml = extractHtml(fullMessage);
      if (!bodyHtml && msg.subject) {
        bodyHtml = `<html><head><title>${msg.subject}</title></head><body><h1>${msg.subject}</h1></body></html>`;
      }

      if (bodyHtml) {
        auditHtml(bodyHtml);
      } else {
        alert('Could not extract HTML body from selected email.');
      }
    } else {
      // Fallback for standalone/mock testing
      auditHtml(`<!DOCTYPE html><html><head><title>Demo Email Newsletter</title><meta name="description" content="Technical SEO insights and newsletter updates"/></head><body><h1>Welcome to our Newsletter</h1><img src="banner.jpg" alt="Company Banner"/><a href="https://seowebchecker.com/">Visit SEOWebChecker</a></body></html>`);
    }
  } catch (err) {
    console.error(err);
    alert('Error auditing message: ' + err.message);
  }
});
