export interface SEOWebCheckerSettings {
  targetWordCount: number;
  minWordCount: number;
  focusKeywordKey: string;
  enableRealtimeAudit: boolean;
  targetReadingLevel: string;
}

export const DEFAULT_SETTINGS: SEOWebCheckerSettings = {
  targetWordCount: 1000,
  minWordCount: 300,
  focusKeywordKey: "focus_keyword",
  enableRealtimeAudit: true,
  targetReadingLevel: "Standard",
};

export type IssueSeverity = "pass" | "info" | "warning" | "critical";

export interface IssueItem {
  id: string;
  title: string;
  message: string;
  severity: IssueSeverity;
}

export interface KeywordData {
  keyword: string;
  count: number;
  densityPercent: number;
  inTitle: boolean;
  inFirstParagraph: boolean;
  inHeadings: boolean;
  inDescription: boolean;
}

export interface AuditResult {
  score: number;
  grade: "A+" | "A" | "B" | "C" | "F";
  wordCount: number;
  characterCount: number;
  sentenceCount: number;
  readingTimeMinutes: number;
  fleschScore: number;
  fleschGrade: string;
  headingCounts: { [key: string]: number };
  headingIssues: IssueItem[];
  frontmatterIssues: IssueItem[];
  contentIssues: IssueItem[];
  imageIssues: IssueItem[];
  linkIssues: IssueItem[];
  keywordData: KeywordData | null;
  passesCount: number;
  warningsCount: number;
  criticalsCount: number;
  timestamp: string;
  platformUrl: string;
}
