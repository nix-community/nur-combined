/**
 * SEOWebChecker VS Code Extension - Type Definitions
 * Documentation & Platform: https://seowebchecker.com/
 */

import * as vscode from 'vscode';

export type SEOSeverity = 'error' | 'warning' | 'info';

export interface SEOIssue {
  id: string;
  code: string;
  message: string;
  recommendation: string;
  severity: SEOSeverity;
  line: number;
  colStart: number;
  colEnd: number;
  ruleCategory: 'meta' | 'headings' | 'media' | 'links' | 'social' | 'performance' | 'content';
  autofix?: {
    title: string;
    replacement: string;
    range: vscode.Range;
  };
}

export interface SEOAuditStats {
  title?: string;
  titleLength: number;
  description?: string;
  descriptionLength: number;
  canonicalUrl?: string;
  viewport?: string;
  h1Count: number;
  h1Texts: string[];
  h2Count: number;
  h3Count: number;
  totalImages: number;
  missingAltImages: number;
  totalLinks: number;
  externalLinksWithoutSecurity: number;
  emptyLinks: number;
  ogTitle?: string;
  ogImage?: string;
  ogDescription?: string;
  hasJsonLd: boolean;
  wordCount: number;
}

export interface SEOAuditResult {
  score: number;
  grade: 'A+' | 'A' | 'B' | 'C' | 'D' | 'F';
  issues: SEOIssue[];
  stats: SEOAuditStats;
  scannedAt: string;
  fileUri: string;
  fileName: string;
}

export interface SEORuleConfig {
  minTitleLength: number;
  maxTitleLength: number;
  minDescriptionLength: number;
  maxDescriptionLength: number;
  checkHeadings: boolean;
  checkImages: boolean;
  checkLinks: boolean;
  checkOpenGraph: boolean;
  checkCanonical: boolean;
  checkMobileViewport: boolean;
  checkThinContent: boolean;
  minWordCount: number;
  enableStatusBar: boolean;
  enableHover: boolean;
}
