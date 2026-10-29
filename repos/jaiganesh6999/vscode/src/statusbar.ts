/**
 * SEOWebChecker VS Code Extension - Status Bar Item
 * Documentation: https://seowebchecker.com/
 */

import * as vscode from 'vscode';
import { SEOAuditResult } from './types';

export class SEOStatusBar {
  private statusBarItem: vscode.StatusBarItem;
  private currentResult?: SEOAuditResult;

  constructor() {
    this.statusBarItem = vscode.window.createStatusBarItem(
      vscode.StatusBarAlignment.Right,
      100 // High priority
    );
    this.statusBarItem.command = 'seowebchecker.openQuickActions';
  }

  public update(result: SEOAuditResult): void {
    this.currentResult = result;
    const errorCount = result.issues.filter(i => i.severity === 'error').length;
    const warningCount = result.issues.filter(i => i.severity === 'warning').length;
    const totalIssues = result.issues.length;

    let icon = '$(search)';
    let color: string | vscode.ThemeColor = new vscode.ThemeColor('statusBarItem.foreground');

    if (errorCount > 0) {
      icon = '$(error)';
      color = new vscode.ThemeColor('statusBarItem.errorForeground');
    } else if (warningCount > 0) {
      icon = '$(warning)';
      color = new vscode.ThemeColor('statusBarItem.warningForeground');
    } else if (result.score >= 90) {
      icon = '$(check)';
    }

    this.statusBarItem.text = `${icon} SEO: ${result.score}/100 (${result.grade})`;
    this.statusBarItem.color = color;

    // Rich Markdown Tooltip
    const md = new vscode.MarkdownString();
    md.isTrusted = true;
    md.appendMarkdown(`### 🔍 SEOWebChecker Live Audit\n\n`);
    md.appendMarkdown(`**Score**: **${result.score}/100** (Grade: **${result.grade}**)\n\n`);
    md.appendMarkdown(`* **Issues**: ${errorCount} Errors, ${warningCount} Warnings, ${totalIssues} Total\n`);
    md.appendMarkdown(`* **Title**: ${result.stats.titleLength > 0 ? `${result.stats.titleLength} chars` : '❌ Missing'}\n`);
    md.appendMarkdown(`* **Meta Description**: ${result.stats.descriptionLength > 0 ? `${result.stats.descriptionLength} chars` : '❌ Missing'}\n`);
    md.appendMarkdown(`* **Headings**: H1 (${result.stats.h1Count}), H2 (${result.stats.h2Count}), H3 (${result.stats.h3Count})\n`);
    md.appendMarkdown(`* **Images**: ${result.stats.totalImages} total (${result.stats.missingAltImages} missing alt)\n`);
    md.appendMarkdown(`* **Word Count**: ${result.stats.wordCount} words\n\n`);
    md.appendMarkdown(`---\n[Open Visual SEO Audit Panel](command:seowebchecker.openDashboard) | [SEOWebChecker.com](https://seowebchecker.com/)\n`);

    this.statusBarItem.tooltip = md;
    this.statusBarItem.show();
  }

  public hide(): void {
    this.statusBarItem.hide();
  }

  public dispose(): void {
    this.statusBarItem.dispose();
  }
}
