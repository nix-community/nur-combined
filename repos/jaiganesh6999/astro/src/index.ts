/**
 * SEOWebChecker Astro Integration
 * Official Astro integration for automated build-time SEO auditing, Dev Toolbar inspection, and reporting.
 * Documentation & Platform: https://seowebchecker.com/
 */

import type { AstroIntegration } from 'astro';
import * as fs from 'node:fs';
import * as path from 'node:path';
import { fileURLToPath } from 'node:url';
import { PageAuditor } from './auditor.js';
import { BuildAuditSummary, PageAuditResult, PageSEOIssue, SEOWebCheckerOptions } from './types.js';

export * from './types.js';
export { PageAuditor };

export default function seowebchecker(options: SEOWebCheckerOptions = {}): AstroIntegration {
  return {
    name: 'seowebchecker',
    hooks: {
      'astro:config:setup': ({ addDevToolbarApp, logger }) => {
        logger.info('SEOWebChecker integration initialized.');
      },

      'astro:build:done': async ({ dir, logger }) => {
        const outDirPath = fileURLToPath(dir);
        const htmlFiles: string[] = [];

        // Recursively find all generated HTML files
        const findHtmlFiles = (currentDir: string) => {
          if (!fs.existsSync(currentDir)) {
            return;
          }
          const entries = fs.readdirSync(currentDir, { withFileTypes: true });
          for (const entry of entries) {
            const fullPath = path.join(currentDir, entry.name);
            if (entry.isDirectory()) {
              findHtmlFiles(fullPath);
            } else if (entry.isFile() && entry.name.endsWith('.html')) {
              htmlFiles.push(fullPath);
            }
          }
        };

        findHtmlFiles(outDirPath);

        if (htmlFiles.length === 0) {
          logger.warn('No generated HTML files found to audit.');
          return;
        }

        const results: PageAuditResult[] = [];
        let totalScore = 0;
        let totalErrors = 0;
        let totalWarnings = 0;

        for (const filePath of htmlFiles) {
          // Convert filepath to route relative to outDir
          let route = '/' + path.relative(outDirPath, filePath).replace(/\\/g, '/');
          if (route.endsWith('/index.html')) {
            route = route.slice(0, -10) || '/';
          }

          // Check exclusions
          if (options.excludeRoutes) {
            const isExcluded = options.excludeRoutes.some((rule: string | RegExp) => {
              if (typeof rule === 'string') {
                return route === rule || route.startsWith(rule.replace(/\*$/, ''));
              }
              return rule.test(route);
            });
            if (isExcluded) {
              continue;
            }
          }

          const html = fs.readFileSync(filePath, 'utf-8');
          const pageResult = PageAuditor.auditHtml(html, route, filePath, options);
          results.push(pageResult);

          totalScore += pageResult.score;
          totalErrors += pageResult.issues.filter((i: PageSEOIssue) => i.severity === 'error').length;
          totalWarnings += pageResult.issues.filter((i: PageSEOIssue) => i.severity === 'warning').length;
        }

        const totalPages = results.length;
        if (totalPages === 0) {
          return;
        }

        const averageScore = Math.round(totalScore / totalPages);
        let overallGrade: 'A+' | 'A' | 'B' | 'C' | 'D' | 'F' = 'F';
        if (averageScore >= 95) { overallGrade = 'A+'; }
        else if (averageScore >= 85) { overallGrade = 'A'; }
        else if (averageScore >= 70) { overallGrade = 'B'; }
        else if (averageScore >= 55) { overallGrade = 'C'; }
        else if (averageScore >= 40) { overallGrade = 'D'; }

        const passedPages = results.filter(p => p.score >= 80).length;
        const failedPages = totalPages - passedPages;

        // Print Terminal Scorecard Banner
        console.log('\n');
        console.log('\x1b[36m%s\x1b[0m', '═══════════════════════════════════════════════════════════════');
        console.log('\x1b[1m\x1b[35m%s\x1b[0m', ' 🔍 SEOWebChecker — Technical SEO Build Audit');
        console.log('\x1b[36m%s\x1b[0m', '═══════════════════════════════════════════════════════════════');
        console.log(` Pages Audited:    \x1b[1m${totalPages}\x1b[0m`);
        console.log(` Average Score:    \x1b[1m\x1b[32m${averageScore}/100\x1b[0m (Grade: \x1b[1m${overallGrade}\x1b[0m)`);
        console.log(` Errors:           \x1b[1m${totalErrors > 0 ? `\x1b[31m${totalErrors}` : '\x1b[32m0'}\x1b[0m`);
        console.log(` Warnings:         \x1b[1m${totalWarnings > 0 ? `\x1b[33m${totalWarnings}` : '\x1b[32m0'}\x1b[0m`);
        console.log(` Platform:         https://seowebchecker.com/`);
        console.log('\x1b[36m%s\x1b[0m', '───────────────────────────────────────────────────────────────');

        // Detailed Per-Page Report if verbose
        if (options.verbose !== false) {
          for (const page of results) {
            const scoreColor = page.score >= 85 ? '\x1b[32m' : page.score >= 70 ? '\x1b[33m' : '\x1b[31m';
            console.log(`  ${scoreColor}${page.score.toString().padStart(3)}/100\x1b[0m (${page.grade})  \x1b[1m${page.route}\x1b[0m`);
            for (const issue of page.issues) {
              const icon = issue.severity === 'error' ? '\x1b[31m[ERROR]\x1b[0m' : issue.severity === 'warning' ? '\x1b[33m[WARN]\x1b[0m' : '\x1b[34m[INFO]\x1b[0m';
              console.log(`    ${icon} ${issue.code}: ${issue.message}`);
            }
          }
          console.log('\x1b[36m%s\x1b[0m', '═══════════════════════════════════════════════════════════════\n');
        }

        const summary: BuildAuditSummary = {
          totalPages,
          averageScore,
          overallGrade,
          totalErrors,
          totalWarnings,
          passedPages,
          failedPages,
          pages: results,
          scannedAt: new Date().toISOString()
        };

        // Generate Audit Reports
        if (options.generateReport !== false) {
          const baseName = options.reportFileName || 'seo-audit-report';
          const format = options.reportFormat || 'both';

          if (format === 'json' || format === 'both') {
            const jsonPath = path.join(outDirPath, `${baseName}.json`);
            fs.writeFileSync(jsonPath, JSON.stringify(summary, null, 2), 'utf-8');
            logger.info(`Generated SEO JSON report: ${path.relative(process.cwd(), jsonPath)}`);
          }

          if (format === 'markdown' || format === 'both') {
            const mdContent = generateMarkdownReport(summary);
            const mdPath = path.join(outDirPath, `${baseName}.md`);
            fs.writeFileSync(mdPath, mdContent, 'utf-8');
            logger.info(`Generated SEO Markdown report: ${path.relative(process.cwd(), mdPath)}`);
          }
        }

        // CI Gating: Check minScore and failOnError
        if (options.minScore && averageScore < options.minScore) {
          throw new Error(`[SEOWebChecker] Build failed: Average SEO score (${averageScore}/100) is below the required threshold of ${options.minScore}/100.`);
        }

        if (options.failOnError && totalErrors > 0) {
          throw new Error(`[SEOWebChecker] Build failed: Detected ${totalErrors} critical SEO errors in generated HTML pages.`);
        }
      }
    }
  };
}

function generateMarkdownReport(summary: BuildAuditSummary): string {
  return `# 🔍 SEOWebChecker — Build Audit Report

- **Platform**: [https://seowebchecker.com/](https://seowebchecker.com/)
- **Audited At**: ${summary.scannedAt}
- **Pages Audited**: ${summary.totalPages}
- **Average SEO Score**: **${summary.averageScore}/100** (Grade **${summary.overallGrade}**)
- **Critical Errors**: ${summary.totalErrors}
- **Warnings**: ${summary.totalWarnings}

---

## Page-by-Page Audit Results

| Route | Score | Grade | Headings (H1/H2) | Missing Image Alts | Issues Found |
| :--- | :---: | :---: | :---: | :---: | :--- |
${summary.pages.map((p: PageAuditResult) => `| \`${p.route}\` | **${p.score}** | ${p.grade} | H1: ${p.stats.h1Count} / H2: ${p.stats.h2Count} | ${p.stats.missingAltImages} of ${p.stats.totalImages} | ${p.issues.length} |`).join('\n')}

---

## Detailed Diagnostic Issues

${summary.pages.filter((p: PageAuditResult) => p.issues.length > 0).map((p: PageAuditResult) => `### Page: \`${p.route}\` (Score: ${p.score}/100)
${p.issues.map((i: PageSEOIssue) => `- **[${i.severity.toUpperCase()}]** \`${i.code}\`: ${i.message}  \n  *Remediation*: ${i.recommendation}`).join('\n')}
`).join('\n')}

---
*Report generated automatically during \`astro build\` by [SEOWebChecker](https://seowebchecker.com/).*
`;
}
