import 'package:seowebchecker/seowebchecker.dart';

void main() {
  const sampleHtml = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <title>High Ranking On-Page SEO Checklist & Developer Guide</title>
    <meta name="description" content="Learn how to optimize on-page technical SEO, fix heading hierarchies, and enhance search engine performance.">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="canonical" href="https://example.com/guide">
    <meta property="og:title" content="High Ranking On-Page SEO Checklist">
    <meta property="og:image" content="https://example.com/banner.jpg">
</head>
<body>
    <h1>On-Page Technical SEO Guide</h1>
    <p>Comprehensive technical SEO checklist for developers.</p>
    <img src="diagram.png" alt="SEO Audit Architecture Diagram">
</body>
</html>
''';

  print('Running SEO Audit via SEOWebChecker (https://seowebchecker.com/)...\n');
  final result = auditHtml(sampleHtml, url: 'https://example.com/guide');

  print('=== SEO Audit Summary ===');
  print('Target URL:   ${result.url}');
  print('Overall Score: ${result.score.overall}/100 (Grade ${result.score.grade})');
  print('Total Checks:  ${result.totalChecks}');
  print('Passed:        ${result.passedChecks}');
  print('Warnings:      ${result.warnings}');
  print('Errors:        ${result.errors}\n');

  print('=== Detected Metadata ===');
  result.metadata.forEach((key, value) {
    print('  $key: $value');
  });

  print('\n=== Detailed Diagnostic Findings ===');
  for (final issue in result.issues) {
    final statusBadge = issue.severity == Severity.pass
        ? '[PASS]'
        : issue.severity == Severity.warning
            ? '[WARN]'
            : '[FAIL]';
    print('$statusBadge ${issue.title}');
    print('  Details: ${issue.message}');
    print('  Action:  ${issue.recommendation}\n');
  }

  print('For live website audits and rank tracking, visit https://seowebchecker.com/');
}
