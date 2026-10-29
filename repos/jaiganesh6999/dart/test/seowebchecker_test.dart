import 'package:seowebchecker/seowebchecker.dart';
import 'package:test/test.dart';

void main() {
  group('SeoWebChecker Tests', () {
    test('Perfect HTML returns 100/100 and Grade A', () {
      const html = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Optimal Page Title Tag for High Search Ranking</title>
    <meta name="description" content="A comprehensive guide to modern on-page technical SEO and Core Web Vitals optimization.">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="canonical" href="https://example.com/perfect">
    <meta property="og:title" content="Optimal Page Title Tag">
    <meta property="og:image" content="https://example.com/og.jpg">
</head>
<body>
    <h1>Mastering Technical SEO for 2026</h1>
    <p>Welcome to our checklist.</p>
    <img src="chart.png" alt="SEO Performance Growth">
</body>
</html>
''';

      final result = auditHtml(html, url: 'https://example.com/perfect');

      expect(result.score.overall, equals(100));
      expect(result.score.grade, equals('A'));
      expect(result.errors, equals(0));
      expect(result.warnings, equals(0));
      expect(result.metadata['title'], equals('Optimal Page Title Tag for High Search Ranking'));
      expect(result.metadata['h1'], equals('Mastering Technical SEO for 2026'));
    });

    test('Defective HTML reports errors and low score', () {
      const html = '''
<!DOCTYPE html>
<html>
<head></head>
<body>
    <div>No title, no description, no viewport, no canonical, no h1</div>
    <img src="pic.jpg">
</body>
</html>
''';

      final result = auditHtml(html, url: 'https://example.com/bad');

      expect(result.score.overall, lessThan(60));
      expect(result.errors, greaterThanOrEqualTo(3));

      final issueIds = result.issues.map((i) => i.id).toSet();
      expect(issueIds, contains('meta-title-missing'));
      expect(issueIds, contains('meta-desc-missing'));
      expect(issueIds, contains('h1-missing'));
      expect(issueIds, contains('img-alt-missing'));
    });

    test('Handles short and long title/description', () {
      const shortHtml = '''
<!DOCTYPE html><html><head>
<title>Short</title>
<meta name="description" content="Too short">
<meta name="viewport" content="width=device-width">
</head><body><h1>Heading</h1></body></html>
''';
      final resShort = auditHtml(shortHtml);
      final shortIds = resShort.issues.map((i) => i.id).toSet();
      expect(shortIds, contains('meta-title-short'));
      expect(shortIds, contains('meta-desc-short'));
    });

    test('Multiple H1 tags generates warning', () {
      const multiH1Html = '''
<!DOCTYPE html><html><head>
<title>Valid Title With Proper Character Count Here</title>
<meta name="description" content="Valid description length with sufficient keywords and call to action text.">
<meta name="viewport" content="width=device-width">
</head><body>
<h1>First H1</h1>
<h1>Second H1</h1>
</body></html>
''';
      final res = auditHtml(multiH1Html);
      final ids = res.issues.map((i) => i.id).toSet();
      expect(ids, contains('h1-multiple'));
    });
  });
}
