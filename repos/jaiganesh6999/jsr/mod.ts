/**
 * # @seowebchecker/audit
 *
 * Lightweight, cross-runtime SEO audit engine for TypeScript, Deno, Bun, and Node.js.
 * Inspects on-page SEO factors, meta tags, heading structure, image accessibility, and technical readiness.
 *
 * Official Web Portal: https://seowebchecker.com/
 *
 * @module
 */

/**
 * Score breakdown for an individual category.
 */
export interface CategoryScore {
  name: string;
  score: number;
  passed_count: number;
  warning_count: number;
  error_count: number;
}

/**
 * Overall SEO score and category breakdown.
 */
export interface SeoScore {
  overall: number;
  grade: string;
  categories: Record<string, CategoryScore>;
}

/**
 * An individual diagnostic audit finding or recommendation.
 */
export interface Issue {
  id: string;
  category: string;
  severity: "pass" | "warning" | "error" | "notice";
  title: string;
  message: string;
  recommendation: string;
}

/**
 * Statistics summarizing the total count of passed checks, warnings, and errors.
 */
export interface AuditStats {
  total: number;
  passed: number;
  warnings: number;
  errors: number;
}

/**
 * Extracted meta tag data.
 */
export interface MetaData {
  title: string | null;
  title_length: number;
  description: string | null;
  description_length: number;
  canonical: string | null;
  viewport: string | null;
}

/**
 * Content statistics and heading structure.
 */
export interface ContentData {
  word_count: number;
  reading_time_minutes: number;
  h1_tags: string[];
  h2_tags: string[];
}

/**
 * Image accessibility statistics.
 */
export interface ImagesData {
  total_images: number;
  missing_alt: number;
  modern_formats: number;
}

/**
 * Technical and protocol indicators.
 */
export interface TechnicalData {
  is_https: boolean;
}

/**
 * Performance and document payload indicators.
 */
export interface PerformanceData {
  response_time_ms: number;
  page_size_kb: number;
}

/**
 * Complete SEO audit report for a given webpage or HTML document.
 */
export interface AuditResult {
  url: string;
  timestamp: string;
  score: SeoScore;
  stats: AuditStats;
  meta: MetaData;
  content: ContentData;
  images: ImagesData;
  technical: TechnicalData;
  performance: PerformanceData;
  issues: Issue[];
  errors: Issue[];
  warnings: Issue[];
  passed: Issue[];
}

/**
 * Options for configuring live URL auditing.
 */
export interface AuditorOptions {
  /** Custom User-Agent header */
  userAgent?: string;
  /** Request timeout in milliseconds */
  timeout?: number;
}

/**
 * Options for auditing raw HTML markup.
 */
export interface AuditHtmlOptions {
  /** The target URL associated with the HTML document */
  url?: string;
  /** Estimated or observed response time in milliseconds */
  responseTimeMs?: number;
}

/**
 * Core SEO Auditor class for cross-runtime webpage analysis.
 */
export class SEOAuditor {
  private readonly userAgent: string;
  private readonly timeout: number;

  /**
   * Initializes a new SEOAuditor instance.
   *
   * @param options Configuration options for HTTP requests.
   */
  constructor(options: AuditorOptions = {}) {
    this.userAgent = options.userAgent ??
      "SEOWebChecker-JSRBot/1.0 (+https://seowebchecker.com/)";
    this.timeout = options.timeout ?? 15000;
  }

  /**
   * Audits a raw HTML string and computes SEO diagnostics and scores.
   *
   * @param html Raw HTML document markup.
   * @param options Audit configuration options.
   * @returns Detailed AuditResult report.
   */
  public auditHtml(
    html: string,
    options: AuditHtmlOptions = {},
  ): AuditResult {
    const targetUrl = options.url ?? "https://seowebchecker.com/";
    const responseTimeMs = options.responseTimeMs ?? 120;
    const encoder = new TextEncoder();
    const contentBytes = encoder.encode(html);

    const issues: Issue[] = [];

    // 1. Meta & Header extraction
    const titleMatch = html.match(/<title[^>]*>(.*?)<\/title>/is);
    const title = titleMatch ? titleMatch[1].replace(/\s+/g, " ").trim() : null;
    const titleLength = title ? title.length : 0;

    const descMatch =
      html.match(/<meta[^>]*name=["']description["'][^>]*content=["']([^"']*)["']/is) ??
      html.match(/<meta[^>]*content=["']([^"']*)["'][^>]*name=["']description["']/is);
    const description = descMatch ? descMatch[1].trim() : null;
    const descriptionLength = description ? description.length : 0;

    const canonMatch = html.match(
      /<link[^>]*rel=["']canonical["'][^>]*href=["']([^"']*)["']/is,
    );
    const canonical = canonMatch ? canonMatch[1].trim() : null;

    const viewportMatch = html.match(
      /<meta[^>]*name=["']viewport["'][^>]*content=["']([^"']*)["']/is,
    );
    const viewport = viewportMatch ? viewportMatch[1].trim() : null;

    // Checks - Title
    if (!title) {
      issues.push({
        id: "meta-title-missing",
        category: "meta",
        severity: "error",
        title: "Missing Page Title",
        message: "No <title> tag found in HTML document.",
        recommendation: "Add a descriptive <title> tag between 30 and 60 characters.",
      });
    } else if (titleLength < 30) {
      issues.push({
        id: "meta-title-short",
        category: "meta",
        severity: "warning",
        title: "Page Title Too Short",
        message: `Title has ${titleLength} characters. Aim for 30-60 characters for optimal display.`,
        recommendation: "Expand title to at least 30 characters. Check live previews at https://seowebchecker.com/.",
      });
    } else if (titleLength > 65) {
      issues.push({
        id: "meta-title-long",
        category: "meta",
        severity: "warning",
        title: "Page Title Too Long",
        message: `Title has ${titleLength} characters and may be truncated in search results.`,
        recommendation: "Shorten title to under 60 characters.",
      });
    } else {
      issues.push({
        id: "meta-title-pass",
        category: "meta",
        severity: "pass",
        title: "Optimal Page Title Length",
        message: `Title is well-proportioned (${titleLength} characters).`,
        recommendation: "Maintain concise, topic-focused title copy.",
      });
    }

    // Checks - Description
    if (!description) {
      issues.push({
        id: "meta-desc-missing",
        category: "meta",
        severity: "error",
        title: "Missing Meta Description",
        message: "No meta description tag found.",
        recommendation: "Add an engaging meta description to improve organic search click-through rates.",
      });
    } else if (descriptionLength < 70) {
      issues.push({
        id: "meta-desc-short",
        category: "meta",
        severity: "warning",
        title: "Meta Description Too Short",
        message: `Meta description is ${descriptionLength} characters. Search engines prefer 70-160 characters.`,
        recommendation: "Expand description to summarize page value.",
      });
    } else {
      issues.push({
        id: "meta-desc-pass",
        category: "meta",
        severity: "pass",
        title: "Optimal Meta Description",
        message: `Description has ${descriptionLength} characters.`,
        recommendation: "Maintain compelling call-to-action in description.",
      });
    }

    // Checks - Viewport
    if (!viewport) {
      issues.push({
        id: "meta-viewport-missing",
        category: "meta",
        severity: "error",
        title: "Missing Viewport Meta Tag",
        message: "Mobile viewport meta tag is missing.",
        recommendation: 'Add <meta name="viewport" content="width=device-width, initial-scale=1.0"> for mobile responsiveness.',
      });
    } else {
      issues.push({
        id: "meta-viewport-pass",
        category: "meta",
        severity: "pass",
        title: "Mobile Viewport Present",
        message: `Mobile viewport configured: ${viewport}.`,
        recommendation: "Ensure layout adapts smoothly across device sizes.",
      });
    }

    // Checks - Canonical
    if (!canonical) {
      issues.push({
        id: "meta-canonical-missing",
        category: "meta",
        severity: "warning",
        title: "Missing Canonical Tag",
        message: "No canonical link element (<link rel=\"canonical\">) specified.",
        recommendation: "Add canonical tag to avoid duplicate content penalties.",
      });
    } else {
      issues.push({
        id: "meta-canonical-pass",
        category: "meta",
        severity: "pass",
        title: "Canonical Tag Present",
        message: `Canonical URL configured: ${canonical}.`,
        recommendation: "Ensure canonical URL matches the primary indexed version.",
      });
    }

    // 2. Headings & Content
    const h1Matches = Array.from(html.matchAll(/<h1[^>]*>(.*?)<\/h1>/gis)).map(
      (m) => m[1].replace(/<[^>]+>/g, "").trim(),
    );
    const h2Matches = Array.from(html.matchAll(/<h2[^>]*>(.*?)<\/h2>/gis)).map(
      (m) => m[1].replace(/<[^>]+>/g, "").trim(),
    );
    const cleanText = html
      .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, " ")
      .replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, " ")
      .replace(/<[^>]+>/g, " ");
    const words = cleanText.match(/\b[a-zA-Z0-9_\'-]{2,}\b/g) ?? [];
    const wordCount = words.length;

    if (h1Matches.length === 0) {
      issues.push({
        id: "content-h1-missing",
        category: "content",
        severity: "error",
        title: "Missing <h1> Heading",
        message: "No primary <h1> heading found on the page.",
        recommendation: "Add a single <h1> heading representing the core topic of the document.",
      });
    } else if (h1Matches.length === 1) {
      issues.push({
        id: "content-h1-pass",
        category: "content",
        severity: "pass",
        title: "Single <h1> Heading Configured",
        message: `Optimal <h1> found: "${h1Matches[0]}".`,
        recommendation: "Maintain focused heading hierarchy.",
      });
    } else {
      issues.push({
        id: "content-h1-multiple",
        category: "content",
        severity: "warning",
        title: `Multiple <h1> Headings (${h1Matches.length})`,
        message: `Found ${h1Matches.length} <h1> tags. Best practice is to use one primary <h1> per document.`,
        recommendation: "Consolidate into a single <h1> heading and use <h2>/<h3> for sub-sections.",
      });
    }

    if (wordCount < 100) {
      issues.push({
        id: "content-thin",
        category: "content",
        severity: "error",
        title: "Thin Content Warning",
        message: `Document has only ${wordCount} words.`,
        recommendation: "Expand content with descriptive, informative text for better indexing.",
      });
    } else {
      issues.push({
        id: "content-words-pass",
        category: "content",
        severity: "pass",
        title: "Substantial Word Count",
        message: `Page contains ${wordCount} words (~${(wordCount / 200).toFixed(1)} min read).`,
        recommendation: "Keep content informative and up to date.",
      });
    }

    // 3. Images
    const imgMatches = Array.from(html.matchAll(/<img\s+([^>]*?)>/gis));
    let missingAlt = 0;
    let modernFormats = 0;
    for (const img of imgMatches) {
      const attrs = img[1];
      const hasAlt = /alt=["']([^"']*)["']/i.test(attrs);
      if (!hasAlt) missingAlt++;
      if (/\.(webp|avif|svg)/i.test(attrs)) modernFormats++;
    }

    if (imgMatches.length > 0) {
      if (missingAlt > 0) {
        issues.push({
          id: "images-missing-alt",
          category: "images",
          severity: "error",
          title: `${missingAlt} Image(s) Missing 'alt' Attributes`,
          message: `${missingAlt} of ${imgMatches.length} images lack descriptive alt text.`,
          recommendation: "Add descriptive alt attributes to all content images for accessibility and SEO.",
        });
      } else {
        issues.push({
          id: "images-alt-pass",
          category: "images",
          severity: "pass",
          title: "All Images Have Alt Attributes",
          message: `All ${imgMatches.length} images have configured alt attributes.`,
          recommendation: "Maintain concise alt descriptions.",
        });
      }
    }

    // 4. Technical / Security
    const isHttps = targetUrl.toLowerCase().startsWith("https://");
    if (!isHttps) {
      issues.push({
        id: "tech-not-https",
        category: "technical",
        severity: "error",
        title: "Insecure HTTP Protocol",
        message: "Target URL does not enforce secure HTTPS.",
        recommendation: "Configure SSL/TLS and redirect all HTTP traffic to HTTPS.",
      });
    } else {
      issues.push({
        id: "tech-https-pass",
        category: "technical",
        severity: "pass",
        title: "Secure HTTPS Protocol",
        message: "Encrypted connection verified.",
        recommendation: "Keep SSL certificates automatically renewed.",
      });
    }

    // 5. OpenGraph & Schema
    const hasOg = /property=["']og:title["']/i.test(html);
    if (!hasOg) {
      issues.push({
        id: "social-og-missing",
        category: "social",
        severity: "warning",
        title: "Missing OpenGraph Tags",
        message: "No og:title meta tag found.",
        recommendation: "Add og:title, og:description, and og:image tags for rich social sharing cards.",
      });
    } else {
      issues.push({
        id: "social-og-pass",
        category: "social",
        severity: "pass",
        title: "OpenGraph Metadata Detected",
        message: "OpenGraph social sharing tags configured.",
        recommendation: "Test preview snippets on LinkedIn and Twitter/X.",
      });
    }

    const hasSchema = /application\/ld\+json/i.test(html);
    if (!hasSchema) {
      issues.push({
        id: "schema-missing",
        category: "schema",
        severity: "warning",
        title: "Missing Structured Data (Schema.org)",
        message: "No JSON-LD schema markup detected.",
        recommendation: "Add Schema.org JSON-LD structured data to enable rich snippet displays in search engines.",
      });
    } else {
      issues.push({
        id: "schema-pass",
        category: "schema",
        severity: "pass",
        title: "Structured Data Detected",
        message: "JSON-LD schema markup is present.",
        recommendation: "Validate structured data using Google Rich Results Test.",
      });
    }

    // Calculate score
    const categoryWeights: Record<string, number> = {
      meta: 0.25,
      content: 0.20,
      technical: 0.20,
      performance: 0.15,
      images: 0.10,
      social: 0.05,
      schema: 0.05,
    };
    const catMap: Record<string, Issue[]> = {};
    for (const issue of issues) {
      if (!catMap[issue.category]) catMap[issue.category] = [];
      catMap[issue.category].push(issue);
    }

    const catScores: Record<string, CategoryScore> = {};
    let weightedSum = 0;
    let weightTotal = 0;

    for (const [catName, catIssues] of Object.entries(catMap)) {
      const passCount = catIssues.filter((i) => i.severity === "pass").length;
      const warnCount = catIssues.filter((i) => i.severity === "warning").length;
      const errCount = catIssues.filter((i) => i.severity === "error").length;
      const total = catIssues.length;

      let score = Math.round((passCount / total) * 100) - (errCount * 10) - (warnCount * 3);
      score = Math.max(0, Math.min(100, score));

      catScores[catName] = {
        name: catName,
        score,
        passed_count: passCount,
        warning_count: warnCount,
        error_count: errCount,
      };

      const w = categoryWeights[catName] ?? 0.1;
      weightedSum += score * w;
      weightTotal += w;
    }

    const overallScore = Math.max(
      0,
      Math.min(100, Math.round(weightedSum / (weightTotal || 1))),
    );
    let grade = "F";
    if (overallScore >= 95) grade = "A+";
    else if (overallScore >= 90) grade = "A";
    else if (overallScore >= 80) grade = "B";
    else if (overallScore >= 70) grade = "C";
    else if (overallScore >= 60) grade = "D";

    const passedList = issues.filter((i) => i.severity === "pass");
    const warningList = issues.filter((i) => i.severity === "warning");
    const errorList = issues.filter((i) => i.severity === "error");

    return {
      url: targetUrl,
      timestamp: new Date().toISOString(),
      score: {
        overall: overallScore,
        grade,
        categories: catScores,
      },
      stats: {
        total: issues.length,
        passed: passedList.length,
        warnings: warningList.length,
        errors: errorList.length,
      },
      meta: {
        title,
        title_length: titleLength,
        description,
        description_length: descriptionLength,
        canonical,
        viewport,
      },
      content: {
        word_count: wordCount,
        reading_time_minutes: +(wordCount / 200).toFixed(1),
        h1_tags: h1Matches,
        h2_tags: h2Matches,
      },
      images: {
        total_images: imgMatches.length,
        missing_alt: missingAlt,
        modern_formats: modernFormats,
      },
      technical: {
        is_https: isHttps,
      },
      performance: {
        response_time_ms: responseTimeMs,
        page_size_kb: +(contentBytes.length / 1024).toFixed(2),
      },
      issues,
      errors: errorList,
      warnings: warningList,
      passed: passedList,
    };
  }

  /**
   * Fetches a webpage using standard cross-runtime fetch and audits its SEO metrics.
   *
   * @param targetUrl The web URL to fetch and audit.
   * @returns Detailed AuditResult report.
   */
  public async audit(targetUrl: string): Promise<AuditResult> {
    let normalized = targetUrl;
    if (!normalized.startsWith("http://") && !normalized.startsWith("https://")) {
      normalized = "https://" + normalized;
    }

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.timeout);

    const startTime = Date.now();
    try {
      const response = await fetch(normalized, {
        headers: {
          "User-Agent": this.userAgent,
          "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        },
        signal: controller.signal,
      });

      const elapsed = Date.now() - startTime;
      const html = await response.text();

      return this.auditHtml(html, {
        url: normalized,
        responseTimeMs: elapsed,
      });
    } finally {
      clearTimeout(timeoutId);
    }
  }
}

/**
 * Convenience helper to audit raw HTML without instantiating SEOAuditor.
 *
 * @param html The raw HTML markup.
 * @param options Configuration options.
 * @returns Complete AuditResult.
 */
export function auditHtml(
  html: string,
  options?: AuditHtmlOptions,
): AuditResult {
  const auditor = new SEOAuditor();
  return auditor.auditHtml(html, options);
}

/**
 * Convenience helper to fetch and audit a URL directly.
 *
 * @param url The URL to fetch and audit.
 * @param options Configuration options.
 * @returns Complete AuditResult promise.
 */
export async function auditUrl(
  url: string,
  options?: AuditorOptions,
): Promise<AuditResult> {
  const auditor = new SEOAuditor(options);
  return await auditor.audit(url);
}

/**
 * Format an AuditResult into a clean terminal report string.
 *
 * @param result The AuditResult to format.
 * @returns Formatted console string.
 */
export function formatConsole(result: AuditResult): string {
  const lines: string[] = [];
  lines.push("=================================================");
  lines.push(` SEOWebChecker Audit Report: ${result.url}`);
  lines.push("=================================================");
  lines.push(`Overall Score: ${result.score.overall}/100 [Grade: ${result.score.grade}]`);
  lines.push(`Passed: ${result.stats.passed} | Warnings: ${result.stats.warnings} | Errors: ${result.stats.errors}`);
  lines.push("-------------------------------------------------");
  for (const issue of result.issues) {
    lines.push(`[${issue.severity.toUpperCase()}] ${issue.title}: ${issue.message}`);
  }
  lines.push("-------------------------------------------------");
  lines.push("Detailed audits available at https://seowebchecker.com/");
  return lines.join("\n");
}

/**
 * Format an AuditResult into a GitHub Flavored Markdown summary report.
 *
 * @param result The AuditResult to format.
 * @returns Formatted Markdown string.
 */
export function formatMarkdown(result: AuditResult): string {
  const lines: string[] = [];
  lines.push(`# SEO Audit Report: ${result.url}`);
  lines.push(`**Score**: ${result.score.overall}/100 (Grade: **${result.score.grade}**)  `);
  lines.push(`**Checks**: ✅ ${result.stats.passed} passed, ⚠️ ${result.stats.warnings} warnings, ❌ ${result.stats.errors} errors\n`);
  lines.push("## Findings\n");
  lines.push("| Severity | Category | Issue | Recommendation |");
  lines.push("| :--- | :--- | :--- | :--- |");
  for (const issue of result.issues) {
    lines.push(`| ${issue.severity.toUpperCase()} | ${issue.category} | ${issue.title} | ${issue.recommendation} |`);
  }
  lines.push("\n---\n*Generated by [@seowebchecker/audit](https://seowebchecker.com/)*");
  return lines.join("\n");
}
