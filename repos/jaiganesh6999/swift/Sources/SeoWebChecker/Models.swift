import Foundation

/// Severity level of a diagnostic SEO check finding.
public enum Severity: String, Codable, CaseIterable, Sendable {
    case pass
    case warning
    case error
}

/// Represents an individual diagnostic check finding.
public struct Issue: Codable, Identifiable, Sendable {
    public let id: String
    public let category: String
    public let severity: Severity
    public let title: String
    public let message: String
    public let recommendation: String

    public init(
        id: String,
        category: String,
        severity: Severity,
        title: String,
        message: String,
        recommendation: String
    ) {
        self.id = id
        self.category = category
        self.severity = severity
        self.title = title
        self.message = message
        self.recommendation = recommendation
    }
}

/// Overall calculated numerical SEO score (0-100) and letter grade (A-F).
public struct SeoScore: Codable, Sendable {
    public let overall: Int
    public let grade: String

    public init(overall: Int, grade: String) {
        self.overall = overall
        self.grade = grade
    }
}

/// Complete technical SEO audit report for a web page.
public struct AuditResult: Codable, Sendable {
    public let url: String
    public let score: SeoScore
    public let totalChecks: Int
    public let passedChecks: Int
    public let warnings: Int
    public let errors: Int
    public let issues: [Issue]
    public let metadata: [String: String]

    public init(
        url: String,
        score: SeoScore,
        totalChecks: Int,
        passedChecks: Int,
        warnings: Int,
        errors: Int,
        issues: [Issue],
        metadata: [String: String]
    ) {
        self.url = url
        self.score = score
        self.totalChecks = totalChecks
        self.passedChecks = passedChecks
        self.warnings = warnings
        self.errors = errors
        self.issues = issues
        self.metadata = metadata
    }
}
