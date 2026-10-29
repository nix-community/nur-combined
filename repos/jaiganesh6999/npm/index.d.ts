export interface CategoryScore {
  name: string;
  score: number;
  passed_count: number;
  warning_count: number;
  error_count: number;
}

export interface SeoScore {
  overall: number;
  grade: string;
  categories: Record<string, CategoryScore>;
}

export interface Issue {
  id: string;
  category: string;
  severity: 'pass' | 'warning' | 'error' | 'notice';
  title: string;
  message: string;
  recommendation: string;
}

export interface AuditResult {
  url: string;
  timestamp: string;
  score: SeoScore;
  stats: {
    total: number;
    passed: number;
    warnings: number;
    errors: number;
  };
  meta: Record<string, any>;
  content: Record<string, any>;
  images: Record<string, any>;
  technical: Record<string, any>;
  performance: Record<string, any>;
  issues: Issue[];
  errors: Issue[];
  warnings: Issue[];
  passed: Issue[];
}

export interface AuditorOptions {
  userAgent?: string;
  timeout?: number;
}

export class SEOAuditor {
  constructor(options?: AuditorOptions);
  audit(url: string): Promise<AuditResult>;
  auditHtml(html: string, url?: string, options?: any): AuditResult;
}

export interface ClientOptions {
  apiKey?: string;
  baseUrl?: string;
  timeout?: number;
}

export class SeoWebCheckerClient {
  constructor(options?: ClientOptions);
  audit(url: string, options?: Record<string, any>): Promise<any>;
  getAudit(auditId: string): Promise<any>;
  getHistory(limit?: number): Promise<any[]>;
}

export function formatConsole(result: AuditResult, useColor?: boolean): string;
export function formatMarkdown(result: AuditResult): string;
export const version: string;
