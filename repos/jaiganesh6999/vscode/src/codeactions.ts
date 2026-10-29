/**
 * SEOWebChecker VS Code Extension - Code Actions & Quick Fixes
 * Documentation: https://seowebchecker.com/
 */

import * as vscode from 'vscode';
import { SEOAnalyzer } from './analyzer';
import { SEORuleConfig } from './types';

export class SEOCodeActionProvider implements vscode.CodeActionProvider {
  public static readonly providedCodeActionKinds = [
    vscode.CodeActionKind.QuickFix
  ];

  constructor(private getConfig: () => SEORuleConfig) {}

  public provideCodeActions(
    document: vscode.TextDocument,
    range: vscode.Range | vscode.Selection,
    context: vscode.CodeActionContext,
    token: vscode.CancellationToken
  ): vscode.CodeAction[] {
    const actions: vscode.CodeAction[] = [];
    const lineText = document.lineAt(range.start.line).text;

    // Filter diagnostics from SEOWebChecker
    for (const diagnostic of context.diagnostics) {
      if (diagnostic.source !== 'SEOWebChecker') {
        continue;
      }

      const codeStr = typeof diagnostic.code === 'object' ? diagnostic.code.value : diagnostic.code;

      // 1. Missing alt attribute on <img>
      if (codeStr === 'SEO-IMG-01') {
        const fix = new vscode.CodeAction('Add empty alt="" attribute for image', vscode.CodeActionKind.QuickFix);
        fix.edit = new vscode.WorkspaceEdit();

        // Find the end of opening <img or <Image
        const imgMatch = lineText.match(/<(img|Image)\b[^>]*>/i);
        if (imgMatch) {
          const insertPos = new vscode.Position(range.start.line, lineText.indexOf(imgMatch[0]) + imgMatch[0].length - 1);
          fix.edit.insert(document.uri, insertPos, ' alt=""');
          fix.isPreferred = true;
          fix.diagnostics = [diagnostic];
          actions.push(fix);
        }
      }

      // 2. Missing rel="noopener noreferrer"
      if (codeStr === 'SEO-LINK-01') {
        const fix = new vscode.CodeAction('Add rel="noopener noreferrer" for security & SEO', vscode.CodeActionKind.QuickFix);
        fix.edit = new vscode.WorkspaceEdit();

        const anchorMatch = lineText.match(/<a\b[^>]*>/i);
        if (anchorMatch) {
          const insertPos = new vscode.Position(range.start.line, lineText.indexOf(anchorMatch[0]) + anchorMatch[0].length - 1);
          fix.edit.insert(document.uri, insertPos, ' rel="noopener noreferrer"');
          fix.isPreferred = true;
          fix.diagnostics = [diagnostic];
          actions.push(fix);
        }
      }

      // 3. Online guide action
      const learnAction = new vscode.CodeAction(`Learn how to resolve ${codeStr} on SEOWebChecker`, vscode.CodeActionKind.QuickFix);
      learnAction.command = {
        title: 'Open SEOWebChecker Documentation',
        command: 'vscode.open',
        arguments: [vscode.Uri.parse('https://seowebchecker.com/')]
      };
      actions.push(learnAction);
    }

    return actions;
  }
}
