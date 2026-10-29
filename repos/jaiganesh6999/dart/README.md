# seowebchecker

[![pub package](https://img.shields.io/pub/v/seowebchecker.svg)](https://pub.dev/packages/seowebchecker)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SEOWebChecker Official](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)

A lightweight Dart and Flutter client SDK for automated on-page technical SEO audits, meta tag validations, heading structure inspections, and Core Web Vitals diagnostics.

Powered by **[SEOWebChecker.com](https://seowebchecker.com/)**.

---

## Features

- 🚀 **Zero Hassle**: Works across Pure Dart (CLI/backend), Flutter (Android, iOS, macOS, Windows, Linux, Web).
- 🔍 **Core SEO Checks**:
  - **Title Tag**: Checks existence and optimal length (30-60 characters).
  - **Meta Description**: Validates length (50-160 characters) and presence.
  - **Mobile Viewport**: Verifies responsive mobile readiness.
  - **Canonical URL**: Detects canonical link tags to prevent duplicate indexing penalties.
  - **Heading Structure**: Ensures exactly one primary `<h1>` tag exists.
  - **Image Accessibility**: Detects missing `alt` attributes on content images.
  - **OpenGraph Tags**: Validates `og:title` and `og:image` for social snippet previews.
- 📊 **Scoring Algorithm**: Calculates a weighted 0-100 SEO score and assigns an industry-standard letter grade (A-F).
- ⚡ **Offline & Online**: Audit raw HTML markup directly in-memory, or crawl live remote web pages via HTTP.

---

## Getting Started

### In a Dart project:

```bash
dart pub add seowebchecker
```

### In a Flutter project:

```bash
flutter pub add seowebchecker
```

---

## Usage

### 1. Audit Raw HTML String

```dart
import 'package:seowebchecker/seowebchecker.dart';

void main() {
  const htmlContent = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <title>High Ranking On-Page SEO Checklist & Guide</title>
    <meta name="description" content="Master technical on-page SEO, heading structure, and Core Web Vitals optimization with our comprehensive developer checklist.">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="canonical" href="https://example.com/guide">
    <meta property="og:title" content="High Ranking On-Page SEO Checklist">
    <meta property="og:image" content="https://example.com/og.jpg">
</head>
<body>
    <h1>On-Page Technical SEO Essentials</h1>
    <p>Optimize your website performance and search rankings.</p>
    <img src="chart.png" alt="SEO Traffic Growth Chart">
</body>
</html>
''';

  final result = auditHtml(htmlContent, url: 'https://example.com/guide');

  print('Overall Score: ${result.score.overall}/100 (Grade ${result.score.grade})');
  print('Checks Passed: ${result.passedChecks}/${result.totalChecks}');
  print('Warnings: ${result.warnings}, Errors: ${result.errors}');

  for (final issue in result.issues) {
    print('  [${issue.severity.name.toUpperCase()}] ${issue.title}: ${issue.message}');
  }
}
```

### 2. Audit a Live Remote URL

```dart
import 'package:seowebchecker/seowebchecker.dart';

Future<void> main() async {
  final auditor = Auditor(
    userAgent: 'MyCustomCrawler/1.0 (+https://seowebchecker.com/)',
  );

  final result = await auditor.auditUrl('https://example.com');
  print('Audited: ${result.url}');
  print('Score: ${result.score.overall}/100 (${result.score.grade})');
}
```

---

## Additional Resources

- **Official Website & Free Online Tools**: [https://seowebchecker.com/](https://seowebchecker.com/)
- **Live Interactive SEO Auditing**: Test your live website at [https://seowebchecker.com/](https://seowebchecker.com/)

---

## License

MIT © 2026 [SEOWebChecker.com](https://seowebchecker.com/).
