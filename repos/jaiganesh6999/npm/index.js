/**
 * SEOWebChecker SEO Audit SDK
 * Official site: https://seowebchecker.com/
 */

const { SEOAuditor } = require('./lib/auditor');
const { SeoWebCheckerClient } = require('./lib/client');
const { formatConsole, formatMarkdown } = require('./lib/formatters');

module.exports = {
  SEOAuditor,
  SeoWebCheckerClient,
  formatConsole,
  formatMarkdown,
  version: '1.0.0',
};
