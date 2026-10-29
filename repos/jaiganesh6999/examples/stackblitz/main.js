import { BrowserSEOAuditor } from './auditor.js';

const auditor = new BrowserSEOAuditor();

// Global polyfill for Buffer if any nested tool inspects window
if (typeof window !== 'undefined' && !window.Buffer) {
  window.Buffer = {
    from: (str) => new TextEncoder().encode(str),
    byteLength: (str) => new TextEncoder().encode(str).length,
  };
}

const htmlInput = document.getElementById('htmlInput');
const runBtn = document.getElementById('runBtn');
const resultCard = document.getElementById('resultCard');
const scoreVal = document.getElementById('scoreVal');
const scoreGrade = document.getElementById('scoreGrade');
const issuesList = document.getElementById('issuesList');

function performAudit() {
  try {
    const html = htmlInput.value;
    const result = auditor.auditHtml(html, 'https://seowebchecker.com/');

    const score = result.score?.overall ?? 100;
    const grade = result.score?.grade ?? 'A';

    scoreVal.textContent = score;
    scoreGrade.textContent = `Grade ${grade}`;

    // Update color styling based on score
    if (score >= 90) {
      scoreVal.style.color = '#10b981';
      document.querySelector('.score-circle').style.borderColor = '#10b981';
    } else if (score >= 70) {
      scoreVal.style.color = '#f59e0b';
      document.querySelector('.score-circle').style.borderColor = '#f59e0b';
    } else {
      scoreVal.style.color = '#ef4444';
      document.querySelector('.score-circle').style.borderColor = '#ef4444';
    }

    issuesList.innerHTML = '';
    const issues = result.issues || [];

    if (issues.length === 0) {
      const emptyNotice = document.createElement('div');
      emptyNotice.className = 'issue-item pass';
      emptyNotice.textContent = 'All on-page SEO best practices and checks passed!';
      issuesList.appendChild(emptyNotice);
    } else {
      issues.forEach(issue => {
        const item = document.createElement('div');
        item.className = `issue-item ${issue.severity || 'info'}`;

        const title = document.createElement('div');
        title.className = 'issue-title';
        title.textContent = `[${(issue.severity || 'INFO').toUpperCase()}] ${issue.title}`;

        const desc = document.createElement('div');
        desc.className = 'issue-desc';
        desc.textContent = issue.message || issue.recommendation;

        item.appendChild(title);
        item.appendChild(desc);
        issuesList.appendChild(item);
      });
    }

    resultCard.style.display = 'block';
  } catch (err) {
    console.error('Audit execution error:', err);
    issuesList.innerHTML = `<div class="issue-item error"><div class="issue-title">[ERROR] Evaluation Failed</div><div class="issue-desc">${err.message}</div></div>`;
    resultCard.style.display = 'block';
  }
}

runBtn.addEventListener('click', performAudit);

// Execute on initial boot
performAudit();
