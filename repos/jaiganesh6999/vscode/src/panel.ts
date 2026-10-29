/**
 * SEOWebChecker VS Code Extension - Visual Audit Webview Panel
 * Documentation: https://seowebchecker.com/
 */

import * as vscode from 'vscode';
import { SEOAuditResult } from './types';

export class SEOWebviewPanel {
  public static currentPanel: SEOWebviewPanel | undefined;
  private readonly panel: vscode.WebviewPanel;
  private disposables: vscode.Disposable[] = [];

  public static createOrShow(extensionUri: vscode.Uri, result: SEOAuditResult): void {
    const column = vscode.window.activeTextEditor ? vscode.ViewColumn.Beside : vscode.ViewColumn.One;

    if (SEOWebviewPanel.currentPanel) {
      SEOWebviewPanel.currentPanel.panel.reveal(column);
      SEOWebviewPanel.currentPanel.update(result);
      return;
    }

    const panel = vscode.window.createWebviewPanel(
      'seowebcheckerAudit',
      'SEOWebChecker Audit',
      column,
      {
        enableScripts: true,
        retainContextWhenHidden: true
      }
    );

    SEOWebviewPanel.currentPanel = new SEOWebviewPanel(panel, extensionUri, result);
  }

  private constructor(panel: vscode.WebviewPanel, extensionUri: vscode.Uri, result: SEOAuditResult) {
    this.panel = panel;
    this.panel.onDidDispose(() => this.dispose(), null, this.disposables);
    this.update(result);

    this.panel.webview.onDidReceiveMessage(
      message => {
        switch (message.command) {
          case 'openExternal':
            vscode.env.openExternal(vscode.Uri.parse(message.url));
            return;
          case 'copyMarkdown':
            vscode.env.clipboard.writeText(message.text);
            vscode.window.showInformationMessage('SEOWebChecker Markdown report copied to clipboard!');
            return;
        }
      },
      null,
      this.disposables
    );
  }

  public update(result: SEOAuditResult): void {
    this.panel.title = `SEO: ${result.fileName}`;
    this.panel.webview.html = this.getHtmlForWebview(result);
  }

  public dispose(): void {
    SEOWebviewPanel.currentPanel = undefined;
    this.panel.dispose();
    while (this.disposables.length) {
      const x = this.disposables.pop();
      if (x) {
        x.dispose();
      }
    }
  }

  private getHtmlForWebview(result: SEOAuditResult): string {
    const gradeColor =
      result.grade === 'A+' || result.grade === 'A' ? '#10b981' :
      result.grade === 'B' ? '#3b82f6' :
      result.grade === 'C' ? '#f59e0b' : '#ef4444';

    const issuesHtml = result.issues.length === 0
      ? `<div class="empty-state">🎉 Outstanding! No technical SEO issues detected in this file.</div>`
      : result.issues.map(issue => `
          <div class="issue-card ${issue.severity}">
            <div class="issue-header">
              <span class="badge ${issue.severity}">${issue.severity.toUpperCase()}</span>
              <span class="issue-code">${issue.code}</span>
              <span class="issue-line">Line ${issue.line + 1}</span>
            </div>
            <div class="issue-msg">${this.escapeHtml(issue.message)}</div>
            <div class="issue-recom">💡 <strong>Remediation:</strong> ${this.escapeHtml(issue.recommendation)}</div>
          </div>
        `).join('');

    const serpTitle = result.stats.title || 'Untitled Document';
    const serpDesc = result.stats.description || 'No meta description provided for this page snippet...';

    return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SEOWebChecker Audit</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      padding: 24px;
      color: var(--vscode-foreground);
      background-color: var(--vscode-editor-background);
      line-height: 1.5;
    }
    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 1px solid var(--vscode-widget-border, #333);
      padding-bottom: 16px;
      margin-bottom: 24px;
    }
    .header h1 {
      margin: 0;
      font-size: 20px;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .score-banner {
      display: flex;
      align-items: center;
      gap: 24px;
      background: var(--vscode-editor-inactiveSelectionBackground, rgba(255,255,255,0.05));
      border: 1px solid var(--vscode-widget-border, #444);
      border-radius: 12px;
      padding: 20px 24px;
      margin-bottom: 24px;
    }
    .score-circle {
      width: 72px;
      height: 72px;
      border-radius: 50%;
      background: ${gradeColor};
      color: #fff;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      font-weight: 800;
      font-size: 22px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    }
    .score-circle span {
      font-size: 11px;
      font-weight: normal;
      opacity: 0.9;
    }
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
      gap: 12px;
      margin-bottom: 24px;
    }
    .stat-box {
      background: var(--vscode-editor-inactiveSelectionBackground, rgba(255,255,255,0.04));
      border: 1px solid var(--vscode-widget-border, #333);
      border-radius: 8px;
      padding: 12px 14px;
      text-align: center;
    }
    .stat-val {
      font-size: 18px;
      font-weight: 700;
      color: var(--vscode-textLink-foreground, #38bdf8);
    }
    .stat-lbl {
      font-size: 11px;
      opacity: 0.8;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-top: 4px;
    }
    .serp-card {
      background: var(--vscode-editor-inactiveSelectionBackground, rgba(255,255,255,0.03));
      border: 1px solid var(--vscode-widget-border, #333);
      border-radius: 10px;
      padding: 18px;
      margin-bottom: 24px;
    }
    .serp-url {
      font-size: 12px;
      color: #10b981;
      margin-bottom: 4px;
      word-break: break-all;
    }
    .serp-title {
      font-size: 17px;
      color: #3b82f6;
      font-weight: 600;
      text-decoration: none;
      display: block;
      margin-bottom: 6px;
    }
    .serp-desc {
      font-size: 13px;
      color: var(--vscode-foreground);
      opacity: 0.85;
      line-height: 1.4;
    }
    .issue-card {
      background: var(--vscode-editor-inactiveSelectionBackground, rgba(255,255,255,0.03));
      border: 1px solid var(--vscode-widget-border, #333);
      border-left: 4px solid #888;
      border-radius: 8px;
      padding: 14px 16px;
      margin-bottom: 12px;
    }
    .issue-card.error { border-left-color: #ef4444; }
    .issue-card.warning { border-left-color: #f59e0b; }
    .issue-card.info { border-left-color: #3b82f6; }
    .issue-header {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 6px;
    }
    .badge {
      font-size: 10px;
      font-weight: 700;
      padding: 2px 6px;
      border-radius: 4px;
      color: #fff;
    }
    .badge.error { background: #ef4444; }
    .badge.warning { background: #f59e0b; color: #111; }
    .badge.info { background: #3b82f6; }
    .issue-code { font-family: monospace; font-size: 11px; opacity: 0.8; }
    .issue-line { font-size: 11px; opacity: 0.6; margin-left: auto; }
    .issue-msg { font-weight: 600; font-size: 13px; margin-bottom: 4px; }
    .issue-recom { font-size: 12px; opacity: 0.85; }
    .btn {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 8px 14px;
      border-radius: 6px;
      background: var(--vscode-button-background);
      color: var(--vscode-button-foreground);
      text-decoration: none;
      cursor: pointer;
      font-size: 12px;
      font-weight: 600;
      border: none;
    }
    .btn:hover { background: var(--vscode-button-hoverBackground); }
    .btn-outline {
      background: transparent;
      border: 1px solid var(--vscode-button-background);
      color: var(--vscode-foreground);
    }
  </style>
</head>
<body>
  <div class="header">
    <h1>🔍 SEOWebChecker Visual Audit</h1>
    <div style="display: flex; gap: 8px;">
      <button class="btn btn-outline" onclick="copyReport()">📋 Copy Markdown</button>
      <button class="btn" onclick="openPlatform()">🌐 SEOWebChecker.com</button>
    </div>
  </div>

  <div class="score-banner">
    <div class="score-circle">
      ${result.score}
      <span>GRADE ${result.grade}</span>
    </div>
    <div>
      <h2 style="margin: 0 0 4px 0; font-size: 16px;">Technical SEO Health Score</h2>
      <p style="margin: 0; opacity: 0.8; font-size: 13px;">
        Evaluated <strong>${result.fileName}</strong> across title tags, descriptions, headings, image alt accessibility, and link security.
      </p>
    </div>
  </div>

  <div class="stats-grid">
    <div class="stat-box">
      <div class="stat-val">${result.stats.titleLength}</div>
      <div class="stat-lbl">Title Length</div>
    </div>
    <div class="stat-box">
      <div class="stat-val">${result.stats.descriptionLength}</div>
      <div class="stat-lbl">Meta Desc Chars</div>
    </div>
    <div class="stat-box">
      <div class="stat-val">${result.stats.h1Count}</div>
      <div class="stat-lbl">H1 Headings</div>
    </div>
    <div class="stat-box">
      <div class="stat-val">${result.stats.totalImages} (${result.stats.missingAltImages} missing)</div>
      <div class="stat-lbl">Image Alts</div>
    </div>
    <div class="stat-box">
      <div class="stat-val">${result.stats.wordCount}</div>
      <div class="stat-lbl">Word Count</div>
    </div>
  </div>

  <div class="serp-card">
    <h3 style="margin: 0 0 10px 0; font-size: 13px; opacity: 0.8; text-transform: uppercase; letter-spacing: 0.5px;">Google SERP Snippet Preview</h3>
    <div class="serp-url">${result.stats.canonicalUrl || 'https://example.com/page'}</div>
    <div class="serp-title">${this.escapeHtml(serpTitle)}</div>
    <div class="serp-desc">${this.escapeHtml(serpDesc)}</div>
  </div>

  <h3 style="margin: 24px 0 12px 0; font-size: 15px;">Diagnostic Checks & Issues (${result.issues.length})</h3>
  <div class="issues-list">
    ${issuesHtml}
  </div>

  <script>
    const vscode = acquireVsCodeApi();
    function openPlatform() {
      vscode.postMessage({ command: 'openExternal', url: 'https://seowebchecker.com/' });
    }
    function copyReport() {
      const markdown = \`# SEOWebChecker Audit Report
**File**: ${result.fileName}
**Score**: ${result.score}/100 (Grade ${result.grade})
**Audited**: ${result.scannedAt}

## Key Metrics
- Title Tag: ${result.stats.titleLength} characters
- Meta Description: ${result.stats.descriptionLength} characters
- H1 Headings: ${result.stats.h1Count}
- Images: ${result.stats.totalImages} total (${result.stats.missingAltImages} missing alt)
- Word Count: ${result.stats.wordCount} words

## Diagnostic Issues
${result.issues.map(i => `- [${i.severity.toUpperCase()}] ${i.code}: ${i.message}`).join('\n')}

Generated by SEOWebChecker: https://seowebchecker.com/\`;
      vscode.postMessage({ command: 'copyMarkdown', text: markdown });
    }
  </script>
</body>
</html>`;
  }

  private escapeHtml(text: string): string {
    return text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }
}
