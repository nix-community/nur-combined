#!/usr/bin/env node

/**
 * CLI runner for seowebchecker-seoaudit-sdk (NPM)
 * Official Tool: https://seowebchecker.com/
 */

const fs = require('fs');
const { SEOAuditor } = require('../lib/auditor');
const { formatConsole, formatMarkdown } = require('../lib/formatters');

const args = process.argv.slice(2);

if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
  console.log(`
SEOWebChecker CLI — Website SEO Audit Tool
Official Website: https://seowebchecker.com/

Usage:
  npx seowebchecker-seoaudit-sdk <url> [options]
  seowebchecker-audit <url> [options]

Options:
  --format <pretty|json|markdown>  Output format (default: pretty)
  --output <file>                  Save output report to file
  --min-score <number>             Minimum acceptable score (exit 1 if failed)
  --no-color                       Disable terminal ANSI colors
  --help, -h                       Display this help message
  --version, -v                    Show version number
  `);
  process.exit(0);
}

if (args.includes('--version') || args.includes('-v')) {
  const pkg = require('../package.json');
  console.log(`seowebchecker-seoaudit-sdk v${pkg.version}`);
  process.exit(0);
}

const targetUrl = args[0];
let format = 'pretty';
let outputFile = null;
let minScore = 0;
let noColor = false;

for (let i = 1; i < args.length; i++) {
  if (args[i] === '--format' && args[i + 1]) {
    format = args[++i];
  } else if (args[i] === '--output' && args[i + 1]) {
    outputFile = args[++i];
  } else if (args[i] === '--min-score' && args[i + 1]) {
    minScore = parseInt(args[++i], 10);
  } else if (args[i] === '--no-color') {
    noColor = true;
  }
}

const auditor = new SEOAuditor();

auditor.audit(targetUrl).then(result => {
  let outputText = '';
  if (format === 'json') {
    outputText = JSON.stringify(result, null, 2);
  } else if (format === 'markdown') {
    outputText = formatMarkdown(result);
  } else {
    outputText = formatConsole(result, !noColor);
  }

  if (outputFile) {
    fs.writeFileSync(outputFile, outputText, 'utf-8');
    console.log(`Report successfully written to ${outputFile}`);
  } else {
    console.log(outputText);
  }

  if (minScore > 0 && result.score.overall < minScore) {
    console.error(`\n[CI/CD ERROR] Score ${result.score.overall} is below required threshold of ${minScore}.`);
    process.exit(1);
  }
}).catch(err => {
  console.error(`Audit failed for ${targetUrl}:`, err.message);
  process.exit(1);
});
