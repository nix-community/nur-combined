/**
 * SEOWebChecker VS Code Extension - Main Entry Point
 * Documentation & Platform: https://seowebchecker.com/
 */

import * as vscode from 'vscode';
import { SEOAnalyzer } from './analyzer';
import { SEODiagnosticsManager } from './diagnostics';
import { SEOStatusBar } from './statusbar';
import { SEOHoverProvider } from './hover';
import { SEOCodeActionProvider } from './codeactions';
import { SEOWebviewPanel } from './panel';
import { SEOAuditResult, SEORuleConfig } from './types';

let diagnosticsManager: SEODiagnosticsManager;
let statusBar: SEOStatusBar;
let latestResult: SEOAuditResult | undefined;

const SUPPORTED_LANGUAGES = [
  'html',
  'javascriptreact',
  'typescriptreact',
  'astro',
  'vue',
  'svelte',
  'php',
  'markdown',
  'mdx'
];

export function activate(context: vscode.ExtensionContext): void {
  diagnosticsManager = new SEODiagnosticsManager();
  statusBar = new SEOStatusBar();

  context.subscriptions.push(diagnosticsManager);
  context.subscriptions.push(statusBar);

  const getConfig = (): SEORuleConfig => {
    const config = vscode.workspace.getConfiguration('seowebchecker');
    return {
      minTitleLength: config.get<number>('minTitleLength', 30),
      maxTitleLength: config.get<number>('maxTitleLength', 60),
      minDescriptionLength: config.get<number>('minDescriptionLength', 70),
      maxDescriptionLength: config.get<number>('maxDescriptionLength', 160),
      checkHeadings: config.get<boolean>('checkHeadings', true),
      checkImages: config.get<boolean>('checkImages', true),
      checkLinks: config.get<boolean>('checkLinks', true),
      checkOpenGraph: config.get<boolean>('checkOpenGraph', true),
      checkCanonical: config.get<boolean>('checkCanonical', true),
      checkMobileViewport: config.get<boolean>('checkMobileViewport', true),
      checkThinContent: config.get<boolean>('checkThinContent', true),
      minWordCount: config.get<number>('minWordCount', 300),
      enableStatusBar: config.get<boolean>('enableStatusBar', true),
      enableHover: config.get<boolean>('enableHover', true)
    };
  };

  const isDocumentSupported = (doc: vscode.TextDocument): boolean => {
    if (SUPPORTED_LANGUAGES.includes(doc.languageId)) {
      return true;
    }
    const ext = doc.fileName.split('.').pop()?.toLowerCase();
    return ['html', 'htm', 'jsx', 'tsx', 'astro', 'vue', 'svelte', 'php', 'md', 'mdx'].includes(ext || '');
  };

  const auditDocument = (document: vscode.TextDocument): void => {
    if (!isDocumentSupported(document)) {
      statusBar.hide();
      return;
    }

    const config = getConfig();
    latestResult = SEOAnalyzer.analyzeDocument(document, config);

    // Update Diagnostics
    diagnosticsManager.updateDiagnostics(document, latestResult);

    // Update Status Bar
    if (config.enableStatusBar) {
      statusBar.update(latestResult);
    } else {
      statusBar.hide();
    }

    // If Webview is open, update it
    if (SEOWebviewPanel.currentPanel) {
      SEOWebviewPanel.currentPanel.update(latestResult);
    }
  };

  // Register Event Listeners
  context.subscriptions.push(
    vscode.window.onDidChangeActiveTextEditor(editor => {
      if (editor) {
        auditDocument(editor.document);
      } else {
        statusBar.hide();
      }
    }),
    vscode.workspace.onDidChangeTextDocument(event => {
      if (vscode.window.activeTextEditor?.document === event.document) {
        auditDocument(event.document);
      }
    }),
    vscode.workspace.onDidSaveTextDocument(document => {
      auditDocument(document);
    }),
    vscode.workspace.onDidCloseTextDocument(document => {
      diagnosticsManager.clearDiagnostics(document.uri);
    })
  );

  // Register Hover Provider
  for (const lang of SUPPORTED_LANGUAGES) {
    context.subscriptions.push(
      vscode.languages.registerHoverProvider(lang, new SEOHoverProvider())
    );
  }

  // Register Code Actions Provider
  for (const lang of SUPPORTED_LANGUAGES) {
    context.subscriptions.push(
      vscode.languages.registerCodeActionsProvider(
        lang,
        new SEOCodeActionProvider(getConfig),
        { providedCodeActionKinds: SEOCodeActionProvider.providedCodeActionKinds }
      )
    );
  }

  // Command: Run Audit
  context.subscriptions.push(
    vscode.commands.registerCommand('seowebchecker.runAudit', () => {
      const editor = vscode.window.activeTextEditor;
      if (!editor) {
        vscode.window.showWarningMessage('Please open an HTML, JSX, TSX, Astro, or Markdown file to run an SEO audit.');
        return;
      }
      auditDocument(editor.document);
      if (latestResult) {
        const msg = `SEOWebChecker: Scored ${latestResult.score}/100 (${latestResult.grade}) with ${latestResult.issues.length} diagnostic issues.`;
        if (latestResult.score >= 85) {
          vscode.window.showInformationMessage(msg, 'View Visual Report').then(selection => {
            if (selection === 'View Visual Report') {
              vscode.commands.executeCommand('seowebchecker.openDashboard');
            }
          });
        } else {
          vscode.window.showWarningMessage(msg, 'View Visual Report').then(selection => {
            if (selection === 'View Visual Report') {
              vscode.commands.executeCommand('seowebchecker.openDashboard');
            }
          });
        }
      }
    })
  );

  // Command: Open Webview Dashboard
  context.subscriptions.push(
    vscode.commands.registerCommand('seowebchecker.openDashboard', () => {
      const editor = vscode.window.activeTextEditor;
      if (!editor) {
        vscode.window.showWarningMessage('Please open a file to view its SEO audit report.');
        return;
      }
      if (!latestResult || latestResult.fileName !== editor.document.fileName) {
        latestResult = SEOAnalyzer.analyzeDocument(editor.document, getConfig());
      }
      SEOWebviewPanel.createOrShow(context.extensionUri, latestResult);
    })
  );

  // Command: Open Quick Actions (from Status Bar click)
  context.subscriptions.push(
    vscode.commands.registerCommand('seowebchecker.openQuickActions', async () => {
      if (!latestResult) {
        const editor = vscode.window.activeTextEditor;
        if (editor) {
          auditDocument(editor.document);
        }
      }

      const scoreText = latestResult ? `Current Score: ${latestResult.score}/100 (Grade ${latestResult.grade})` : 'Run Audit';

      const items: vscode.QuickPickItem[] = [
        {
          label: '$(graph) Open Visual SEO Audit Panel',
          description: scoreText,
          detail: 'Shows circular score gauge, SERP snippet preview, and category breakdown.'
        },
        {
          label: '$(list-unordered) Focus Problems Panel',
          detail: 'View all highlighted SEO issues and code locations in the Problems tray.'
        },
        {
          label: '$(markdown) Export Report as Markdown',
          detail: 'Creates a clean markdown summary of issues and recommendations.'
        },
        {
          label: '$(json) Export Report as JSON',
          detail: 'Exports raw diagnostic metrics and issue payloads.'
        },
        {
          label: '$(globe) Open SEOWebChecker Platform',
          detail: 'Access full domain crawls, historic tracking, and Core Web Vitals at https://seowebchecker.com/'
        }
      ];

      const selected = await vscode.window.showQuickPick(items, {
        placeHolder: 'SEOWebChecker: Select an SEO Action'
      });

      if (!selected) {
        return;
      }

      if (selected.label.includes('Visual SEO Audit Panel')) {
        vscode.commands.executeCommand('seowebchecker.openDashboard');
      } else if (selected.label.includes('Focus Problems Panel')) {
        vscode.commands.executeCommand('workbench.actions.view.problems');
      } else if (selected.label.includes('Export Report as Markdown')) {
        vscode.commands.executeCommand('seowebchecker.exportMarkdown');
      } else if (selected.label.includes('Export Report as JSON')) {
        vscode.commands.executeCommand('seowebchecker.exportJson');
      } else if (selected.label.includes('Open SEOWebChecker Platform')) {
        vscode.env.openExternal(vscode.Uri.parse('https://seowebchecker.com/'));
      }
    })
  );

  // Command: Export Markdown
  context.subscriptions.push(
    vscode.commands.registerCommand('seowebchecker.exportMarkdown', async () => {
      if (!latestResult) {
        vscode.window.showWarningMessage('No active SEO audit available to export.');
        return;
      }

      const mdContent = `# Technical SEO Audit Report: ${latestResult.fileName}

- **Platform Reference**: https://seowebchecker.com/
- **SEO Health Score**: **${latestResult.score}/100** (Grade: **${latestResult.grade}**)
- **Audited At**: ${latestResult.scannedAt}

## Key Metrics
- **Title Tag**: ${latestResult.stats.titleLength > 0 ? `${latestResult.stats.titleLength} characters ("${latestResult.stats.title}")` : 'Missing'}
- **Meta Description**: ${latestResult.stats.descriptionLength > 0 ? `${latestResult.stats.descriptionLength} characters` : 'Missing'}
- **Heading Hierarchy**: H1: ${latestResult.stats.h1Count}, H2: ${latestResult.stats.h2Count}, H3: ${latestResult.stats.h3Count}
- **Images**: ${latestResult.stats.totalImages} total (${latestResult.stats.missingAltImages} missing alt attributes)
- **Links**: ${latestResult.stats.totalLinks} total (${latestResult.stats.externalLinksWithoutSecurity} insecure external links)
- **Word Count**: ${latestResult.stats.wordCount} words

## Diagnostic Issues (${latestResult.issues.length})
${latestResult.issues.length === 0 ? '_No issues detected! Excellent on-page SEO._' : latestResult.issues.map(i => `### [${i.severity.toUpperCase()}] ${i.code} (Line ${i.line + 1})
- **Issue**: ${i.message}
- **Remediation**: ${i.recommendation}
`).join('\n')}

---
_Generated by SEOWebChecker VS Code Extension. Visit [SEOWebChecker.com](https://seowebchecker.com/) for comprehensive site monitoring._
`;

      const doc = await vscode.workspace.openTextDocument({
        content: mdContent,
        language: 'markdown'
      });
      await vscode.window.showTextDocument(doc);
    })
  );

  // Command: Export JSON
  context.subscriptions.push(
    vscode.commands.registerCommand('seowebchecker.exportJson', async () => {
      if (!latestResult) {
        vscode.window.showWarningMessage('No active SEO audit available to export.');
        return;
      }
      const jsonContent = JSON.stringify(latestResult, null, 2);
      const doc = await vscode.workspace.openTextDocument({
        content: jsonContent,
        language: 'json'
      });
      await vscode.window.showTextDocument(doc);
    })
  );

  // Audit active editor upon launch
  if (vscode.window.activeTextEditor) {
    auditDocument(vscode.window.activeTextEditor.document);
  }
}

export function deactivate(): void {
  if (diagnosticsManager) {
    diagnosticsManager.dispose();
  }
  if (statusBar) {
    statusBar.dispose();
  }
}
