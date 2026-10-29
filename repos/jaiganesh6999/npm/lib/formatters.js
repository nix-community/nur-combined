/**
 * Formatters for SEOWebChecker NPM SDK
 */

const colors = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  dim: '\x1b[2m',
  red: '\x1b[91m',
  green: '\x1b[92m',
  yellow: '\x1b[93m',
  blue: '\x1b[94m',
  cyan: '\x1b[96m',
  bgGreen: '\x1b[42m\x1b[30m',
  bgYellow: '\x1b[43m\x1b[30m',
  bgRed: '\x1b[41m\x1b[97m',
};

function formatConsole(result, useColor = true) {
  const c = useColor ? colors : Object.keys(colors).reduce((acc, k) => { acc[k] = ''; return acc; }, {});
  const score = result.score.overall;
  const grade = result.score.grade;

  let badge = `${c.bgGreen} GRADE ${grade} (${score}/100) ${c.reset}`;
  let scoreColor = c.green;
  if (score < 70) {
    badge = `${c.bgRed} GRADE ${grade} (${score}/100) ${c.reset}`;
    scoreColor = c.red;
  } else if (score < 90) {
    badge = `${c.bgYellow} GRADE ${grade} (${score}/100) ${c.reset}`;
    scoreColor = c.yellow;
  }

  const lines = [];
  lines.push(`${c.cyan}${'='.repeat(68)}${c.reset}`);
  lines.push(`${c.bold} SEOWebChecker SEO Audit Report: ${result.url}${c.reset}`);
  lines.push(` ${c.dim}Official: https://seowebchecker.com/ | Generated: ${result.timestamp}${c.reset}`);
  lines.push(`${c.cyan}${'='.repeat(68)}${c.reset}\n`);

  lines.push(` Overall Score: ${scoreColor}${c.bold}${score}/100${c.reset}  |  Grade: ${badge}`);
  lines.push(` Checks: ${c.green}${result.stats.passed} Passed${c.reset}, ${c.yellow}${result.stats.warnings} Warnings${c.reset}, ${c.red}${result.stats.errors} Errors${c.reset}\n`);

  lines.push(`${c.bold}Category Breakdown:${c.reset}`);
  for (const [catName, cat] of Object.entries(result.score.categories)) {
    const barLen = Math.floor(cat.score / 5);
    const bar = '█'.repeat(barLen) + '░'.repeat(20 - barLen);
    const catColor = cat.score >= 85 ? c.green : (cat.score >= 70 ? c.yellow : c.red);
    lines.push(`  • ${catName.padEnd(14)} [${catColor}${bar}${c.reset}] ${catColor}${String(cat.score).padStart(3)}/100${c.reset} (${cat.passed_count} pass, ${cat.warning_count} warn, ${cat.error_count} err)`);
  }

  lines.push(`\n${c.bold}Key Metadata & Signals:${c.reset}`);
  lines.push(`  • Title: ${result.meta.title || '[MISSING]'} (${result.meta.title_length} chars)`);
  lines.push(`  • Description: ${result.meta.description || '[MISSING]'} (${result.meta.description_length} chars)`);
  lines.push(`  • Canonical: ${result.meta.canonical || '[MISSING]'}`);
  lines.push(`  • Word Count: ${result.content.word_count} words (~${result.content.reading_time_minutes} min read)`);
  lines.push(`  • Response Time: ${result.performance.response_time_ms} ms (Size: ${result.performance.page_size_kb} KB)`);
  lines.push(`  • Images: ${result.images.total_images} total (${result.images.missing_alt} missing alt)`);

  if (result.errors && result.errors.length > 0) {
    lines.push(`\n${c.red}${c.bold}[!] High Priority Issues (Errors):${c.reset}`);
    for (const err of result.errors) {
      lines.push(`  ${c.red}✖ ${err.title}${c.reset}`);
      lines.push(`    Message: ${err.message}`);
      lines.push(`    Action:  ${c.dim}${err.recommendation}${c.reset}`);
    }
  }

  if (result.warnings && result.warnings.length > 0) {
    lines.push(`\n${c.yellow}${c.bold}[~] Recommended Improvements (Warnings):${c.reset}`);
    for (const warn of result.warnings) {
      lines.push(`  ${c.yellow}▲ ${warn.title}${c.reset}`);
      lines.push(`    Message: ${warn.message}`);
      lines.push(`    Action:  ${c.dim}${warn.recommendation}${c.reset}`);
    }
  }

  lines.push(`\n${c.cyan}${'-'.repeat(68)}${c.reset}`);
  lines.push(` Run full online audit at: https://seowebchecker.com/`);
  lines.push(`${c.cyan}${'-'.repeat(68)}${c.reset}`);

  return lines.join('\n');
}

function formatMarkdown(result) {
  const lines = [];
  lines.push(`# SEO Audit Report: ${result.url}\n`);
  lines.push(`> Audited with [SEOWebChecker](https://seowebchecker.com/) on \`${result.timestamp}\`\n`);
  lines.push(`## Executive Summary\n`);
  lines.push(`- **Overall Score:** **\`${result.score.overall}/100\`** (Grade: **${result.score.grade}**)`);
  lines.push(`- **Passed Checks:** \`${result.stats.passed}\``);
  lines.push(`- **Warnings:** \`${result.stats.warnings}\``);
  lines.push(`- **Errors:** \`${result.stats.errors}\`\n`);

  lines.push(`### Category Scores\n`);
  lines.push(`| Category | Score | Passed | Warnings | Errors |`);
  lines.push(`| :--- | :---: | :---: | :---: | :---: |`);
  for (const [catName, cat] of Object.entries(result.score.categories)) {
    lines.push(`| ${catName} | **${cat.score}/100** | ${cat.passed_count} | ${cat.warning_count} | ${cat.error_count} |`);
  }
  lines.push('');

  if (result.errors && result.errors.length > 0) {
    lines.push(`## High Priority Issues (Errors)\n`);
    for (const err of result.errors) {
      lines.push(`### ❌ ${err.title}`);
      lines.push(`- **Category:** \`${err.category}\``);
      lines.push(`- **Issue:** ${err.message}`);
      lines.push(`- **Recommendation:** ${err.recommendation}\n`);
    }
  }

  lines.push(`---\n*Automate SEO audits with [seowebchecker-seoaudit-sdk](https://seowebchecker.com/).*`);
  return lines.join('\n');
}

module.exports = { formatConsole, formatMarkdown };
