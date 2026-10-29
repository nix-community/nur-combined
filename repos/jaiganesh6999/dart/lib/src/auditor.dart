import 'package:http/http.dart' as http;
import 'models.dart';

/// Engine to execute automated on-page technical SEO audits.
class Auditor {
  final String userAgent;
  final http.Client _client;
  final bool _isCustomClient;

  Auditor({
    this.userAgent = 'SEOWebChecker-DartBot/1.0 (+https://seowebchecker.com/)',
    http.Client? client,
  })  : _client = client ?? http.Client(),
        _isCustomClient = client != null;

  static final _titleRegex = RegExp(r'<title[^>]*>(.*?)</title>', caseSensitive: false, dotAll: true);
  static final _metaDesc1 = RegExp(r'<meta\s+[^>]*name=["\x27]description["\x27][^>]*content=["\x27](.*?)["\x27][^>]*>', caseSensitive: false, dotAll: true);
  static final _metaDesc2 = RegExp(r'<meta\s+[^>]*content=["\x27](.*?)["\x27][^>]*name=["\x27]description["\x27][^>]*>', caseSensitive: false, dotAll: true);
  static final _viewportRegex = RegExp(r'<meta\s+[^>]*name=["\x27]viewport["\x27][^>]*>', caseSensitive: false, dotAll: true);
  static final _canonicalRegex = RegExp(r'<link\s+[^>]*rel=["\x27]canonical["\x27][^>]*href=["\x27](.*?)["\x27][^>]*>', caseSensitive: false, dotAll: true);
  static final _h1Regex = RegExp(r'<h1[^>]*>(.*?)</h1>', caseSensitive: false, dotAll: true);
  static final _stripTags = RegExp(r'<[^>]*>', caseSensitive: false, dotAll: true);
  static final _imgRegex = RegExp(r'<img\s+([^>]*?)>', caseSensitive: false, dotAll: true);
  static final _altAttr = RegExp(r'''alt\s*=\s*["'][^"']*["']''', caseSensitive: false);
  static final _ogTitleRegex = RegExp(r'<meta\s+[^>]*property=["\x27]og:title["\x27][^>]*content=["\x27](.*?)["\x27][^>]*>', caseSensitive: false, dotAll: true);
  static final _ogImageRegex = RegExp(r'<meta\s+[^>]*property=["\x27]og:image["\x27][^>]*content=["\x27](.*?)["\x27][^>]*>', caseSensitive: false, dotAll: true);

  /// Evaluates raw HTML markup against technical on-page SEO best practices.
  AuditResult auditHtml(String htmlContent, {String url = 'https://example.com'}) {
    final issues = <Issue>[];
    final metadata = <String, String>{};

    void addIssue({
      required String id,
      required String category,
      required Severity severity,
      required String title,
      required String message,
      required String recommendation,
    }) {
      issues.add(Issue(
        id: id,
        category: category,
        severity: severity,
        title: title,
        message: message,
        recommendation: recommendation,
      ));
    }

    // 1. Title Tag Check
    final titleMatch = _titleRegex.firstMatch(htmlContent);
    if (titleMatch != null) {
      final rawTitle = titleMatch.group(1)?.trim() ?? '';
      metadata['title'] = rawTitle;
      final length = rawTitle.length;
      if (length < 30) {
        addIssue(
          id: 'meta-title-short',
          category: 'meta',
          severity: Severity.warning,
          title: 'Title Too Short',
          message: 'Title has $length characters. Recommended length is 30-60 characters.',
          recommendation: 'Expand title to 30-60 characters. Validate live search snippets at https://seowebchecker.com.',
        );
      } else if (length > 65) {
        addIssue(
          id: 'meta-title-long',
          category: 'meta',
          severity: Severity.warning,
          title: 'Title Too Long',
          message: 'Title has $length characters. Titles exceeding 65 characters risk truncation.',
          recommendation: 'Shorten title to between 30 and 60 characters.',
        );
      } else {
        addIssue(
          id: 'meta-title-pass',
          category: 'meta',
          severity: Severity.pass,
          title: 'Optimal Title Length',
          message: 'Title length is optimal ($length characters).',
          recommendation: 'Maintain keyword focus and accurate brand positioning.',
        );
      }
    } else {
      addIssue(
        id: 'meta-title-missing',
        category: 'meta',
        severity: Severity.error,
        title: 'Missing Title Tag',
        message: 'No <title> tag found in HTML head.',
        recommendation: 'Add a concise, keyword-rich <title> tag between 30 and 60 characters.',
      );
    }

    // 2. Meta Description Check
    var descMatch = _metaDesc1.firstMatch(htmlContent);
    descMatch ??= _metaDesc2.firstMatch(htmlContent);

    if (descMatch != null) {
      final rawDesc = descMatch.group(1)?.trim() ?? '';
      metadata['description'] = rawDesc;
      final length = rawDesc.length;
      if (length < 50) {
        addIssue(
          id: 'meta-desc-short',
          category: 'meta',
          severity: Severity.warning,
          title: 'Meta Description Too Short',
          message: 'Description has $length characters. Recommended length is 50-160 characters.',
          recommendation: 'Provide more informative copy explaining page value.',
        );
      } else if (length > 165) {
        addIssue(
          id: 'meta-desc-long',
          category: 'meta',
          severity: Severity.warning,
          title: 'Meta Description Too Long',
          message: 'Description has $length characters. Snippets over 160 characters risk truncation.',
          recommendation: 'Shorten description under 160 characters.',
        );
      } else {
        addIssue(
          id: 'meta-desc-pass',
          category: 'meta',
          severity: Severity.pass,
          title: 'Optimal Meta Description',
          message: 'Meta description length is optimal ($length characters).',
          recommendation: 'Keep copy engaging with a strong call-to-action.',
        );
      }
    } else {
      addIssue(
        id: 'meta-desc-missing',
        category: 'meta',
        severity: Severity.error,
        title: 'Missing Meta Description',
        message: 'No <meta name="description"> tag found.',
        recommendation: 'Add an engaging meta description to improve organic search click-through rates.',
      );
    }

    // 3. Mobile Viewport Check
    if (_viewportRegex.hasMatch(htmlContent)) {
      addIssue(
        id: 'mobile-viewport-pass',
        category: 'mobile',
        severity: Severity.pass,
        title: 'Mobile Viewport Present',
        message: 'Mobile viewport meta tag is properly configured.',
        recommendation: 'Ensure responsive CSS breakpoints render smoothly on mobile displays.',
      );
    } else {
      addIssue(
        id: 'mobile-viewport-missing',
        category: 'mobile',
        severity: Severity.error,
        title: 'Missing Viewport Meta Tag',
        message: 'No mobile viewport meta tag found.',
        recommendation: 'Add <meta name="viewport" content="width=device-width, initial-scale=1.0">.',
      );
    }

    // 4. Canonical Tag Check
    final canonMatch = _canonicalRegex.firstMatch(htmlContent);
    if (canonMatch != null) {
      final canonUrl = canonMatch.group(1)?.trim() ?? '';
      metadata['canonical'] = canonUrl;
      addIssue(
        id: 'canonical-pass',
        category: 'indexability',
        severity: Severity.pass,
        title: 'Canonical Tag Present',
        message: 'Canonical link tag is properly specified.',
        recommendation: 'Verify canonical URL matches primary indexed URL.',
      );
    } else {
      addIssue(
        id: 'canonical-missing',
        category: 'indexability',
        severity: Severity.warning,
        title: 'Missing Canonical URL',
        message: 'No <link rel="canonical"> tag found.',
        recommendation: 'Add a canonical link tag to prevent duplicate content issues.',
      );
    }

    // 5. Heading Structure Check (H1)
    final h1Matches = _h1Regex.allMatches(htmlContent).toList();
    if (h1Matches.isEmpty) {
      addIssue(
        id: 'h1-missing',
        category: 'structure',
        severity: Severity.error,
        title: 'Missing H1 Tag',
        message: 'No primary <h1> heading found on the page.',
        recommendation: 'Add a single descriptive <h1> heading communicating page topic.',
      );
    } else if (h1Matches.length > 1) {
      addIssue(
        id: 'h1-multiple',
        category: 'structure',
        severity: Severity.warning,
        title: 'Multiple H1 Tags',
        message: 'Found ${h1Matches.length} <h1> tags. Best practice is to use one primary <h1>.',
        recommendation: 'Consolidate multiple <h1> tags into <h2> subheadings.',
      );
    } else {
      final cleanH1 = (h1Matches[0].group(1) ?? '').replaceAll(_stripTags, '').trim();
      metadata['h1'] = cleanH1;
      addIssue(
        id: 'h1-pass',
        category: 'structure',
        severity: Severity.pass,
        title: 'Single H1 Tag Configured',
        message: 'Primary <h1> heading is present: "$cleanH1".',
        recommendation: 'Ensure H1 matches target search intent.',
      );
    }

    // 6. Image Accessibility Check
    final imgMatches = _imgRegex.allMatches(htmlContent).toList();
    if (imgMatches.isNotEmpty) {
      var missingAlt = 0;
      for (final img in imgMatches) {
        final attrs = img.group(1) ?? '';
        if (!_altAttr.hasMatch(attrs)) {
          missingAlt++;
        }
      }
      if (missingAlt > 0) {
        addIssue(
          id: 'img-alt-missing',
          category: 'accessibility',
          severity: Severity.warning,
          title: 'Images Missing Alt Text',
          message: '$missingAlt image(s) lack descriptive alt attributes.',
          recommendation: 'Add alt attributes to all content images for accessibility and image search indexing.',
        );
      } else {
        addIssue(
          id: 'img-alt-pass',
          category: 'accessibility',
          severity: Severity.pass,
          title: 'Image Alt Attributes Valid',
          message: 'All ${imgMatches.length} images contain alt attributes.',
          recommendation: 'Keep image descriptions descriptive and concise.',
        );
      }
    }

    // 7. OpenGraph Social Tags Check
    final hasOgTitle = _ogTitleRegex.hasMatch(htmlContent);
    final hasOgImage = _ogImageRegex.hasMatch(htmlContent);
    if (hasOgTitle && hasOgImage) {
      addIssue(
        id: 'social-og-pass',
        category: 'social',
        severity: Severity.pass,
        title: 'OpenGraph Social Tags Present',
        message: 'OpenGraph title and social preview image are configured.',
        recommendation: 'Test rich snippet display across LinkedIn, Twitter, and Facebook.',
      );
    } else {
      addIssue(
        id: 'social-og-missing',
        category: 'social',
        severity: Severity.warning,
        title: 'Incomplete OpenGraph Tags',
        message: 'Missing og:title or og:image social sharing meta tags.',
        recommendation: 'Add OpenGraph meta tags to maximize social media click-through rates.',
      );
    }

    var passedCount = 0;
    var warningCount = 0;
    var errorCount = 0;
    for (final iss in issues) {
      switch (iss.severity) {
        case Severity.pass:
          passedCount++;
          break;
        case Severity.warning:
          warningCount++;
          break;
        case Severity.error:
          errorCount++;
          break;
      }
    }

    var scoreNum = 100 - (errorCount * 15) - (warningCount * 5);
    if (scoreNum < 0) scoreNum = 0;
    if (scoreNum > 100) scoreNum = 100;

    String grade = 'F';
    if (scoreNum >= 90) {
      grade = 'A';
    } else if (scoreNum >= 80) {
      grade = 'B';
    } else if (scoreNum >= 70) {
      grade = 'C';
    } else if (scoreNum >= 60) {
      grade = 'D';
    }

    return AuditResult(
      url: url,
      score: SeoScore(overall: scoreNum, grade: grade),
      totalChecks: issues.length,
      passedChecks: passedCount,
      warnings: warningCount,
      errors: errorCount,
      issues: issues,
      metadata: metadata,
    );
  }

  /// Fetches a live web page and runs technical on-page SEO audits.
  Future<AuditResult> auditUrl(String targetUrl) async {
    final uri = Uri.parse(targetUrl);
    final response = await _client.get(uri, headers: {
      'User-Agent': userAgent,
    });

    if (response.statusCode >= 400) {
      throw Exception('HTTP ${response.statusCode} fetching $targetUrl');
    }

    return auditHtml(response.body, url: targetUrl);
  }

  /// Closes internal HTTP client if created automatically.
  void close() {
    if (!_isCustomClient) {
      _client.close();
    }
  }
}

/// Convenience top-level function to audit raw HTML markup.
AuditResult auditHtml(String htmlContent, {String url = 'https://example.com'}) {
  return Auditor().auditHtml(htmlContent, url: url);
}

/// Convenience top-level function to fetch and audit a remote website URL.
Future<AuditResult> auditUrl(String targetUrl, {String? userAgent}) async {
  final auditor = Auditor(userAgent: userAgent ?? 'SEOWebChecker-DartBot/1.0 (+https://seowebchecker.com/)');
  try {
    return await auditor.auditUrl(targetUrl);
  } finally {
    auditor.close();
  }
}
