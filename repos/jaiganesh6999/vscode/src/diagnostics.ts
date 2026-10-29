/**
 * SEOWebChecker VS Code Extension - Diagnostics Manager
 * Documentation: https://seowebchecker.com/
 */

import * as vscode from 'vscode';
import { SEOAuditResult, SEOIssue } from './types';

export class SEODiagnosticsManager {
  private diagnosticCollection: vscode.DiagnosticCollection;

  constructor() {
    this.diagnosticCollection = vscode.languages.createDiagnosticCollection('seowebchecker');
  }

  public updateDiagnostics(document: vscode.TextDocument, result: SEOAuditResult): void {
    const diagnostics: vscode.Diagnostic[] = [];

    for (const issue of result.issues) {
      // Ensure range is within document bounds
      const line = Math.min(Math.max(0, issue.line), Math.max(0, document.lineCount - 1));
      const lineText = document.lineAt(line).text;
      const startCol = Math.min(Math.max(0, issue.colStart), lineText.length);
      const endCol = Math.max(startCol + 1, Math.min(Math.max(startCol + 1, issue.colEnd), lineText.length));

      const range = new vscode.Range(new vscode.Position(line, startCol), new vscode.Position(line, endCol));

      let severity = vscode.DiagnosticSeverity.Information;
      if (issue.severity === 'error') {
        severity = vscode.DiagnosticSeverity.Error;
      } else if (issue.severity === 'warning') {
        severity = vscode.DiagnosticSeverity.Warning;
      }

      const diagnostic = new vscode.Diagnostic(range, `${issue.message} — ${issue.recommendation}`, severity);

      diagnostic.source = 'SEOWebChecker';
      diagnostic.code = {
        value: issue.code,
        target: vscode.Uri.parse('https://seowebchecker.com/')
      };

      diagnostics.push(diagnostic);
    }

    this.diagnosticCollection.set(document.uri, diagnostics);
  }

  public clearDiagnostics(uri: vscode.Uri): void {
    this.diagnosticCollection.delete(uri);
  }

  public dispose(): void {
    this.diagnosticCollection.dispose();
  }
}
