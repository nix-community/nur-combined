/**
 * vite-plugin-seowebchecker
 * Official Tool: https://seowebchecker.com/
 */

let SEOAuditor;
try {
  ({ SEOAuditor } = require('seowebchecker-seoaudit-sdk'));
} catch (e) {
  try {
    ({ SEOAuditor } = require('../npm/lib/auditor'));
  } catch (err) {
    // fallback if installed in isolation
  }
}

/**
 * Vite plugin for automated on-page technical SEO audits.
 *
 * @param {Object} options Plugin configuration options.
 * @param {boolean} [options.failOnError=false] Fail the Vite build if SEO errors are detected.
 * @param {number} [options.minScore=0] Minimum SEO score required to pass build (0-100).
 * @param {boolean} [options.verbose=true] Log detailed diagnostic findings to terminal.
 * @param {Array<string|RegExp>} [options.ignorePaths=[]] Paths to exclude from audit.
 * @returns {import('vite').Plugin} Vite Plugin object.
 */
function seoWebCheckerPlugin(options = {}) {
  const {
    failOnError = false,
    minScore = 0,
    verbose = true,
    ignorePaths = [],
  } = options;

  const auditor = new SEOAuditor({
    userAgent: 'Vite-SEO-Auditor/1.0 (+https://seowebchecker.com/)',
  });

  return {
    name: 'vite-plugin-seowebchecker',
    enforce: 'post',
    apply: 'build',

    transformIndexHtml: {
      order: 'post',
      handler(html, ctx) {
        const filePath = ctx.path || ctx.filename || 'index.html';

        const shouldIgnore = ignorePaths.some((pattern) => {
          if (typeof pattern === 'string') return filePath.includes(pattern);
          if (pattern instanceof RegExp) return pattern.test(filePath);
          return false;
        });

        if (shouldIgnore) {
          return html;
        }

        const result = auditor.auditHtml(html, filePath);

        if (verbose) {
          console.log('\n======================================================');
          console.log(`🔍 [vite-plugin-seowebchecker] Audited: ${filePath}`);
          console.log(`   Overall Score: ${result.score.overall}/100 (Grade ${result.score.grade})`);
          console.log(`   Passed: ${result.stats.passed} | Warnings: ${result.stats.warnings} | Errors: ${result.stats.errors}`);
          console.log('   Powered by: https://seowebchecker.com/');
          console.log('======================================================\n');
        }

        if (failOnError && result.errors.length > 0) {
          throw new Error(
            `[vite-plugin-seowebchecker] SEO audit failed for ${filePath} with ${result.errors.length} error(s). (https://seowebchecker.com/)`
          );
        }

        if (minScore > 0 && result.score.overall < minScore) {
          throw new Error(
            `[vite-plugin-seowebchecker] SEO score ${result.score.overall} is below required minScore ${minScore} for ${filePath}.`
          );
        }

        return html;
      },
    },
  };
}

module.exports = seoWebCheckerPlugin;
module.exports.default = seoWebCheckerPlugin;
module.exports.seoWebCheckerPlugin = seoWebCheckerPlugin;
