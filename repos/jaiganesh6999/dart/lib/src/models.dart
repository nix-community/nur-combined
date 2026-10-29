/// Severity level of a diagnostic SEO check finding.
enum Severity {
  pass,
  warning,
  error,
}

/// Represents an individual diagnostic check finding.
class Issue {
  final String id;
  final String category;
  final Severity severity;
  final String title;
  final String message;
  final String recommendation;

  const Issue({
    required this.id,
    required this.category,
    required this.severity,
    required this.title,
    required this.message,
    required this.recommendation,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'severity': severity.name,
        'title': title,
        'message': message,
        'recommendation': recommendation,
      };

  @override
  String toString() => '[$severity] $title: $message';
}

/// Overall calculated numerical SEO score (0-100) and letter grade (A-F).
class SeoScore {
  final int overall;
  final String grade;

  const SeoScore({
    required this.overall,
    required this.grade,
  });

  Map<String, dynamic> toJson() => {
        'overall': overall,
        'grade': grade,
      };

  @override
  String toString() => '$overall/100 (Grade $grade)';
}

/// Complete technical SEO audit result for a page.
class AuditResult {
  final String url;
  final SeoScore score;
  final int totalChecks;
  final int passedChecks;
  final int warnings;
  final int errors;
  final List<Issue> issues;
  final Map<String, String> metadata;

  const AuditResult({
    required this.url,
    required this.score,
    required this.totalChecks,
    required this.passedChecks,
    required this.warnings,
    required this.errors,
    required this.issues,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'score': score.toJson(),
        'total_checks': totalChecks,
        'passed_checks': passedChecks,
        'warnings': warnings,
        'errors': errors,
        'issues': issues.map((i) => i.toJson()).toList(),
        'metadata': metadata,
      };

  @override
  String toString() =>
      'AuditResult(url: $url, score: $score, passed: $passedChecks, warnings: $warnings, errors: $errors)';
}
