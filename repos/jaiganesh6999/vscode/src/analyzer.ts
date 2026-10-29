/**
 * SEOWebChecker VS Code Extension - Technical SEO Analyzer
 * Real-time parser for HTML, JSX, TSX, Astro, Vue, Svelte, and Markdown.
 * Platform & Documentation: https://seowebchecker.com/
 */

import * as vscode from 'vscode';
import { SEOAuditResult, SEOAuditStats, SEOIssue, SEORuleConfig } from './types';

export class SEOAnalyzer {
  public static analyzeDocument(
    document: vscode.TextDocument,
    config: SEORuleConfig
  ): SEOAuditResult {
    const text = document.getText();
    const lines = text.split(/\r?\n/);
    const issues: SEOIssue[] = [];

    const isMarkdown = document.languageId === 'markdown' || document.fileName.endsWith('.md') || document.fileName.endsWith('.mdx');
    const isComponent = ['javascriptreact', 'typescriptreact', 'astro', 'vue', 'svelte'].includes(document.languageId) ||
      /\.(jsx|tsx|astro|vue|svelte)$/i.test(document.fileName);

    const stats: SEOAuditStats = {
      titleLength: 0,
      descriptionLength: 0,
      h1Count: 0,
      h1Texts: [],
      h2Count: 0,
      h3Count: 0,
      totalImages: 0,
      missingAltImages: 0,
      totalLinks: 0,
      externalLinksWithoutSecurity: 0,
      emptyLinks: 0,
      hasJsonLd: false,
      wordCount: 0
    };

    // 1. Analyze Title
    this.checkTitle(document, text, lines, isMarkdown, isComponent, config, issues, stats);

    // 2. Analyze Meta Description
    this.checkMetaDescription(document, text, lines, isMarkdown, isComponent, config, issues, stats);

    // 3. Analyze Headings (H1, H2, H3)
    if (config.checkHeadings) {
      this.checkHeadings(document, text, lines, isMarkdown, issues, stats);
    }

    // 4. Analyze Images & Alt Attributes
    if (config.checkImages) {
      this.checkImages(document, text, lines, isMarkdown, issues, stats);
    }

    // 5. Analyze Links & External Anchor Security
    if (config.checkLinks) {
      this.checkLinks(document, text, lines, issues, stats);
    }

    // 6. Analyze Mobile Viewport (For standalone HTML / Astro pages)
    if (config.checkMobileViewport && !isComponent && !isMarkdown) {
      this.checkViewport(document, text, lines, issues, stats);
    }

    // 7. Analyze Canonical Link Tag
    if (config.checkCanonical && !isComponent && !isMarkdown) {
      this.checkCanonical(document, text, lines, issues, stats);
    }

    // 8. Analyze OpenGraph Tags
    if (config.checkOpenGraph && !isMarkdown) {
      this.checkOpenGraph(document, text, lines, issues, stats);
    }

    // 9. Analyze Schema.org JSON-LD Structured Data
    this.checkJsonLd(document, text, lines, issues, stats);

    // 10. Word Count
    const strippedText = text.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
    const words = strippedText.length > 0 ? strippedText.split(/\s+/).length : 0;
    stats.wordCount = words;

    if (config.checkThinContent && !isComponent && words > 0 && words < config.minWordCount) {
      issues.push({
        id: 'thin-content',
        code: 'SEO-CONTENT-01',
        message: `Thin content detected: only ${words} words found (recommended: ≥${config.minWordCount} words for indexable pages).`,
        recommendation: `Expand the primary content to provide thorough, helpful answers for users and search crawlers. Reference: https://seowebchecker.com/`,
        severity: 'info',
        line: 0,
        colStart: 0,
        colEnd: lines[0]?.length || 0,
        ruleCategory: 'content'
      });
    }

    // Calculate overall 0-100 Score and Letter Grade
    const score = this.calculateScore(issues, stats);
    const grade = this.calculateGrade(score);

    return {
      score,
      grade,
      issues,
      stats,
      scannedAt: new Date().toISOString(),
      fileUri: document.uri.toString(),
      fileName: document.fileName
    };
  }

  private static checkTitle(
    document: vscode.TextDocument,
    text: string,
    lines: string[],
    isMarkdown: boolean,
    isComponent: boolean,
    config: SEORuleConfig,
    issues: SEOIssue[],
    stats: SEOAuditStats
  ): void {
    let title = '';
    let lineIdx = 0;
    let colStart = 0;
    let colEnd = 0;
    let found = false;

    // Check frontmatter title for Markdown / Astro
    const frontmatterMatch = text.match(/^---\s*[\r\n]+([\s\S]*?)[\r\n]+---/);
    if (frontmatterMatch) {
      const fmLines = frontmatterMatch[1].split(/\r?\n/);
      for (let i = 0; i < fmLines.length; i++) {
        const fmTitleMatch = fmLines[i].match(/^\s*title\s*:\s*["']?([^"'\r\n]+)["']?/i);
        if (fmTitleMatch) {
          title = fmTitleMatch[1].trim();
          lineIdx = i + 1; // +1 for the opening ---
          colStart = fmLines[i].indexOf(fmTitleMatch[1]);
          colEnd = colStart + fmTitleMatch[1].length;
          found = true;
          break;
        }
      }
    }

    // HTML / JSX / Next.js <title> tag
    if (!found) {
      for (let i = 0; i < lines.length; i++) {
        const titleMatch = lines[i].match(/<title[^>]*>([\s\S]*?)<\/title>/i);
        if (titleMatch) {
          title = titleMatch[1].trim();
          lineIdx = i;
          colStart = lines[i].indexOf(titleMatch[0]);
          colEnd = colStart + titleMatch[0].length;
          found = true;
          break;
        }
      }
    }

    if (found) {
      stats.title = title;
      stats.titleLength = title.length;

      if (title.length < config.minTitleLength) {
        issues.push({
          id: 'title-too-short',
          code: 'SEO-TITLE-02',
          message: `Title tag is too short (${title.length} characters). Recommended: ${config.minTitleLength}–${config.maxTitleLength} characters.`,
          recommendation: `Expand your title tag with descriptive keywords and your primary topic to maximize search click-through rate. Learn more: https://seowebchecker.com/`,
          severity: 'warning',
          line: lineIdx,
          colStart,
          colEnd,
          ruleCategory: 'meta'
        });
      } else if (title.length > config.maxTitleLength) {
        issues.push({
          id: 'title-too-long',
          code: 'SEO-TITLE-03',
          message: `Title tag is too long (${title.length} characters). Search engines will truncate titles exceeding ~${config.maxTitleLength} characters.`,
          recommendation: `Condense your title tag to fit within ${config.minTitleLength}–${config.maxTitleLength} characters so the full title displays in search result snippets.`,
          severity: 'warning',
          line: lineIdx,
          colStart,
          colEnd,
          ruleCategory: 'meta'
        });
      }
    } else if (!isComponent) {
      // Missing title in full page
      issues.push({
        id: 'title-missing',
        code: 'SEO-TITLE-01',
        message: 'Missing <title> tag. The page title is the single most critical on-page SEO ranking signal.',
        recommendation: `Add a unique, descriptive <title> tag between 30 and 60 characters in your <head> section. Reference: https://seowebchecker.com/`,
        severity: 'error',
        line: 0,
        colStart: 0,
        colEnd: lines[0]?.length || 0,
        ruleCategory: 'meta'
      });
    }
  }

  private static checkMetaDescription(
    document: vscode.TextDocument,
    text: string,
    lines: string[],
    isMarkdown: boolean,
    isComponent: boolean,
    config: SEORuleConfig,
    issues: SEOIssue[],
    stats: SEOAuditStats
  ): void {
    let desc = '';
    let lineIdx = 0;
    let colStart = 0;
    let colEnd = 0;
    let found = false;

    // Check frontmatter description
    const frontmatterMatch = text.match(/^---\s*[\r\n]+([\s\S]*?)[\r\n]+---/);
    if (frontmatterMatch) {
      const fmLines = frontmatterMatch[1].split(/\r?\n/);
      for (let i = 0; i < fmLines.length; i++) {
        const fmDescMatch = fmLines[i].match(/^\s*description\s*:\s*["']?([^"'\r\n]+)["']?/i);
        if (fmDescMatch) {
          desc = fmDescMatch[1].trim();
          lineIdx = i + 1;
          colStart = fmLines[i].indexOf(fmDescMatch[1]);
          colEnd = colStart + fmDescMatch[1].length;
          found = true;
          break;
        }
      }
    }

    // HTML / JSX meta description
    if (!found) {
      for (let i = 0; i < lines.length; i++) {
        const metaMatch = lines[i].match(/<meta\s+[^>]*name=["']description["'][^>]*content=["']([^"']*)["'][^>]*>/i) ||
                          lines[i].match(/<meta\s+[^>]*content=["']([^"']*)["'][^>]*name=["']description["'][^>]*>/i);
        if (metaMatch) {
          desc = metaMatch[1].trim();
          lineIdx = i;
          colStart = lines[i].indexOf(metaMatch[0]);
          colEnd = colStart + metaMatch[0].length;
          found = true;
          break;
        }
      }
    }

    if (found) {
      stats.description = desc;
      stats.descriptionLength = desc.length;

      if (desc.length < config.minDescriptionLength) {
        issues.push({
          id: 'meta-description-too-short',
          code: 'SEO-DESC-02',
          message: `Meta description is too short (${desc.length} characters). Recommended: ${config.minDescriptionLength}–${config.maxDescriptionLength} characters.`,
          recommendation: `Provide a persuasive summary highlighting key page benefits between ${config.minDescriptionLength} and ${config.maxDescriptionLength} characters. Guide: https://seowebchecker.com/`,
          severity: 'warning',
          line: lineIdx,
          colStart,
          colEnd,
          ruleCategory: 'meta'
        });
      } else if (desc.length > config.maxDescriptionLength) {
        issues.push({
          id: 'meta-description-too-long',
          code: 'SEO-DESC-03',
          message: `Meta description is too long (${desc.length} characters). Google will truncate descriptions over ~${config.maxDescriptionLength} characters.`,
          recommendation: `Shorten your meta description to under ${config.maxDescriptionLength} characters to prevent truncation in search engine snippets.`,
          severity: 'warning',
          line: lineIdx,
          colStart,
          colEnd,
          ruleCategory: 'meta'
        });
      }
    } else if (!isComponent) {
      issues.push({
        id: 'meta-description-missing',
        code: 'SEO-DESC-01',
        message: 'Missing meta description. Search engines rely on meta descriptions for the snippet summary in organic search results.',
        recommendation: `Add <meta name="description" content="..."> with 70–160 characters in your <head> section. Reference: https://seowebchecker.com/`,
        severity: 'warning',
        line: 0,
        colStart: 0,
        colEnd: lines[0]?.length || 0,
        ruleCategory: 'meta'
      });
    }
  }

  private static checkHeadings(
    document: vscode.TextDocument,
    text: string,
    lines: string[],
    isMarkdown: boolean,
    issues: SEOIssue[],
    stats: SEOAuditStats
  ): void {
    const h1Positions: { line: number; colStart: number; colEnd: number; text: string }[] = [];

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];

      // Markdown # Heading
      if (isMarkdown) {
        const mdH1 = line.match(/^#\s+(.+)$/);
        if (mdH1) {
          h1Positions.push({
            line: i,
            colStart: 0,
            colEnd: line.length,
            text: mdH1[1].trim()
          });
          stats.h1Count++;
          stats.h1Texts.push(mdH1[1].trim());
        }
        if (/^##\s+/.test(line)) {
          stats.h2Count++;
        }
        if (/^###\s+/.test(line)) {
          stats.h3Count++;
        }
        continue;
      }

      // HTML / JSX <h1>
      const h1Matches = line.matchAll(/<h1[^>]*>([\s\S]*?)<\/h1>/gi);
      for (const m of h1Matches) {
        const cleanH1 = m[1].replace(/<[^>]+>/g, '').trim();
        const start = m.index ?? 0;
        h1Positions.push({
          line: i,
          colStart: start,
          colEnd: start + m[0].length,
          text: cleanH1
        });
        stats.h1Count++;
        stats.h1Texts.push(cleanH1);
      }

      // H2 & H3 counters
      const h2Matches = line.matchAll(/<h2[^>]*>/gi);
      for (const _ of h2Matches) {
        stats.h2Count++;
      }
      const h3Matches = line.matchAll(/<h3[^>]*>/gi);
      for (const _ of h3Matches) {
        stats.h3Count++;
      }
    }

    if (h1Positions.length === 0) {
      issues.push({
        id: 'h1-missing',
        code: 'SEO-H1-01',
        message: 'Missing primary <h1> heading. Every indexable webpage should have exactly one <h1> representing the main topic.',
        recommendation: `Add a clear, keyword-targeted <h1> heading to establish topic hierarchy for search engines and accessibility screen readers.`,
        severity: 'warning',
        line: 0,
        colStart: 0,
        colEnd: lines[0]?.length || 0,
        ruleCategory: 'headings'
      });
    } else if (h1Positions.length > 1) {
      // Flag all secondary H1s as warnings
      for (let k = 1; k < h1Positions.length; k++) {
        const pos = h1Positions[k];
        issues.push({
          id: `h1-duplicate-${k}`,
          code: 'SEO-H1-02',
          message: `Multiple <h1> tags detected (${h1Positions.length} total). Found duplicate: "${pos.text.substring(0, 40)}${pos.text.length > 40 ? '...' : ''}".`,
          recommendation: `Convert secondary <h1> headings into <h2> subheadings. Pages should have only one primary <h1>. Guide: https://seowebchecker.com/`,
          severity: 'warning',
          line: pos.line,
          colStart: pos.colStart,
          colEnd: pos.colEnd,
          ruleCategory: 'headings'
        });
      }
    }
  }

  private static checkImages(
    document: vscode.TextDocument,
    text: string,
    lines: string[],
    isMarkdown: boolean,
    issues: SEOIssue[],
    stats: SEOAuditStats
  ): void {
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];

      // Markdown image: ![alt](url)
      if (isMarkdown) {
        const mdImgMatches = line.matchAll(/!\[(.*?)\]\((.*?)\)/g);
        for (const m of mdImgMatches) {
          stats.totalImages++;
          const alt = m[1].trim();
          const start = m.index ?? 0;
          if (alt.length === 0) {
            stats.missingAltImages++;
            issues.push({
              id: `img-missing-alt-md-${i}-${start}`,
              code: 'SEO-IMG-01',
              message: 'Markdown image is missing descriptive alt text: ![](...)',
              recommendation: 'Add clear, descriptive alt text inside the square brackets for search engine image indexing and accessibility.',
              severity: 'warning',
              line: i,
              colStart: start,
              colEnd: start + m[0].length,
              ruleCategory: 'media'
            });
          }
        }
      }

      // HTML / JSX / Astro <img> or <Image /> components
      const imgMatches = line.matchAll(/<(img|Image)\b([^>]*)>/gi);
      for (const m of imgMatches) {
        stats.totalImages++;
        const tagName = m[1];
        const attrs = m[2];
        const start = m.index ?? 0;
        const end = start + m[0].length;

        // Check if alt attribute exists
        const hasAltAttr = /\balt\s*=\s*(["'][^"']*["']|\{[^}]*\})/i.test(attrs);

        if (!hasAltAttr) {
          stats.missingAltImages++;
          // Generate quick fix
          const replacement = `<${tagName}${attrs} alt=""`;
          const range = new vscode.Range(new vscode.Position(i, start), new vscode.Position(i, end - 1));

          issues.push({
            id: `img-missing-alt-${i}-${start}`,
            code: 'SEO-IMG-01',
            message: `Image element <${tagName}> is missing an "alt" attribute.`,
            recommendation: `Provide descriptive alt text describing the image content for image search indexing and screen reader accessibility. Details: https://seowebchecker.com/`,
            severity: 'warning',
            line: i,
            colStart: start,
            colEnd: end,
            ruleCategory: 'media',
            autofix: {
              title: 'Add alt="" attribute',
              replacement: `${m[0].slice(0, -1)} alt="" >`,
              range: new vscode.Range(new vscode.Position(i, start), new vscode.Position(i, end))
            }
          });
        } else {
          // Check for redundant alt text like "image of..." or "picture of..."
          const altValMatch = attrs.match(/\balt\s*=\s*["']([^"']*)["']/i);
          if (altValMatch) {
            const altText = altValMatch[1].trim().toLowerCase();
            if (/^(image of|picture of|photo of|graphic of)\b/i.test(altText)) {
              issues.push({
                id: `img-redundant-alt-${i}-${start}`,
                code: 'SEO-IMG-02',
                message: `Redundant alt text phrasing ("${altValMatch[1]}"). Screen readers already announce image tags.`,
                recommendation: `Remove phrases like "image of" or "picture of" and describe the actual subject directly.`,
                severity: 'info',
                line: i,
                colStart: start,
                colEnd: end,
                ruleCategory: 'media'
              });
            }
          }
        }
      }
    }
  }

  private static checkLinks(
    document: vscode.TextDocument,
    text: string,
    lines: string[],
    issues: SEOIssue[],
    stats: SEOAuditStats
  ): void {
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];

      // External links with target="_blank" missing rel="noopener" or rel="noreferrer"
      const anchorMatches = line.matchAll(/<a\b([^>]*)>/gi);
      for (const m of anchorMatches) {
        stats.totalLinks++;
        const attrs = m[1];
        const start = m.index ?? 0;
        const end = start + m[0].length;

        const isTargetBlank = /\btarget\s*=\s*["']_blank["']/i.test(attrs);
        const hasRelNoopener = /\brel\s*=\s*["'][^"']*\b(noopener|noreferrer)\b[^"']*["']/i.test(attrs);

        if (isTargetBlank && !hasRelNoopener) {
          stats.externalLinksWithoutSecurity++;
          issues.push({
            id: `link-blank-security-${i}-${start}`,
            code: 'SEO-LINK-01',
            message: 'External link with target="_blank" is missing rel="noopener" or rel="noreferrer".',
            recommendation: 'Always add rel="noopener noreferrer" to external links to prevent reverse tabnabbing security exploits and maintain performance.',
            severity: 'warning',
            line: i,
            colStart: start,
            colEnd: end,
            ruleCategory: 'links',
            autofix: {
              title: 'Add rel="noopener noreferrer"',
              replacement: `${m[0].slice(0, -1)} rel="noopener noreferrer">`,
              range: new vscode.Range(new vscode.Position(i, start), new vscode.Position(i, end))
            }
          });
        }
      }
    }
  }

  private static checkViewport(
    document: vscode.TextDocument,
    text: string,
    lines: string[],
    issues: SEOIssue[],
    stats: SEOAuditStats
  ): void {
    const viewportMatch = text.match(/<meta\s+[^>]*name=["']viewport["'][^>]*content=["']([^"']*)["'][^>]*>/i) ||
                          text.match(/<meta\s+[^>]*content=["']([^"']*)["'][^>]*name=["']viewport["'][^>]*>/i);

    if (viewportMatch) {
      stats.viewport = viewportMatch[1];
      if (/maximum-scale\s*=\s*1\.0/i.test(viewportMatch[1]) || /user-scalable\s*=\s*no/i.test(viewportMatch[1])) {
        issues.push({
          id: 'viewport-zoom-disabled',
          code: 'SEO-VIEWPORT-02',
          message: 'Mobile viewport disables user pinch-to-zoom (user-scalable=no or maximum-scale=1.0). This fails Core Web Vitals mobile accessibility standards.',
          recommendation: 'Allow user zooming by setting content="width=device-width, initial-scale=1.0". Reference: https://seowebchecker.com/',
          severity: 'warning',
          line: 0,
          colStart: 0,
          colEnd: lines[0]?.length || 0,
          ruleCategory: 'meta'
        });
      }
    } else {
      issues.push({
        id: 'viewport-missing',
        code: 'SEO-VIEWPORT-01',
        message: 'Missing mobile viewport meta tag. Google uses mobile-first indexing for all websites.',
        recommendation: 'Add <meta name="viewport" content="width=device-width, initial-scale=1.0"> inside your <head>.',
        severity: 'error',
        line: 0,
        colStart: 0,
        colEnd: lines[0]?.length || 0,
        ruleCategory: 'meta'
      });
    }
  }

  private static checkCanonical(
    document: vscode.TextDocument,
    text: string,
    lines: string[],
    issues: SEOIssue[],
    stats: SEOAuditStats
  ): void {
    const canonicalMatch = text.match(/<link\s+[^>]*rel=["']canonical["'][^>]*href=["']([^"']*)["'][^>]*>/i) ||
                           text.match(/<link\s+[^>]*href=["']([^"']*)["'][^>]*rel=["']canonical["'][^>]*>/i);

    if (canonicalMatch) {
      stats.canonicalUrl = canonicalMatch[1];
    } else {
      issues.push({
        id: 'canonical-missing',
        code: 'SEO-CANONICAL-01',
        message: 'Missing canonical link tag (<link rel="canonical" href="...">).',
        recommendation: 'Specify a self-referential canonical URL to prevent duplicate content indexing penalties across query parameters and protocols.',
        severity: 'info',
        line: 0,
        colStart: 0,
        colEnd: lines[0]?.length || 0,
        ruleCategory: 'meta'
      });
    }
  }

  private static checkOpenGraph(
    document: vscode.TextDocument,
    text: string,
    lines: string[],
    issues: SEOIssue[],
    stats: SEOAuditStats
  ): void {
    const ogTitle = text.match(/<meta\s+[^>]*property=["']og:title["'][^>]*content=["']([^"']*)["']/i);
    const ogImage = text.match(/<meta\s+[^>]*property=["']og:image["'][^>]*content=["']([^"']*)["']/i);
    const ogDesc = text.match(/<meta\s+[^>]*property=["']og:description["'][^>]*content=["']([^"']*)["']/i);

    if (ogTitle) { stats.ogTitle = ogTitle[1]; }
    if (ogImage) { stats.ogImage = ogImage[1]; }
    if (ogDesc) { stats.ogDescription = ogDesc[1]; }

    if (!ogTitle || !ogImage) {
      issues.push({
        id: 'og-tags-incomplete',
        code: 'SEO-OG-01',
        message: `Incomplete OpenGraph tags: ${!ogTitle ? 'og:title missing; ' : ''}${!ogImage ? 'og:image missing;' : ''}`,
        recommendation: 'Add og:title and og:image meta tags to ensure eye-catching preview cards on LinkedIn, X/Twitter, and Facebook.',
        severity: 'info',
        line: 0,
        colStart: 0,
        colEnd: lines[0]?.length || 0,
        ruleCategory: 'social'
      });
    }
  }

  private static checkJsonLd(
    document: vscode.TextDocument,
    text: string,
    lines: string[],
    issues: SEOIssue[],
    stats: SEOAuditStats
  ): void {
    const scriptMatches = text.matchAll(/<script\s+[^>]*type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/gi);
    for (const m of scriptMatches) {
      stats.hasJsonLd = true;
      const jsonContent = m[1].trim();
      try {
        JSON.parse(jsonContent);
      } catch (err: any) {
        issues.push({
          id: 'jsonld-invalid-syntax',
          code: 'SEO-SCHEMA-01',
          message: `Invalid Schema.org JSON-LD syntax: ${err.message}`,
          recommendation: 'Verify your Schema.org structured data JSON syntax to ensure Google Rich Snippets can parse it correctly.',
          severity: 'error',
          line: 0,
          colStart: 0,
          colEnd: lines[0]?.length || 0,
          ruleCategory: 'social'
        });
      }
    }
  }

  private static calculateScore(issues: SEOIssue[], stats: SEOAuditStats): number {
    let score = 100;
    for (const issue of issues) {
      if (issue.severity === 'error') {
        score -= 20;
      } else if (issue.severity === 'warning') {
        score -= 8;
      } else if (issue.severity === 'info') {
        score -= 2;
      }
    }
    return Math.max(0, Math.min(100, score));
  }

  private static calculateGrade(score: number): 'A+' | 'A' | 'B' | 'C' | 'D' | 'F' {
    if (score >= 95) { return 'A+'; }
    if (score >= 85) { return 'A'; }
    if (score >= 70) { return 'B'; }
    if (score >= 55) { return 'C'; }
    if (score >= 40) { return 'D'; }
    return 'F';
  }
}
