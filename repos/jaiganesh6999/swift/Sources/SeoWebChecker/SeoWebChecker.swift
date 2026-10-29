import Foundation

/// Top-level public interface for SEOWebChecker Swift SDK.
public enum SeoWebChecker: Sendable {
    private static let defaultAuditor = Auditor()

    /// Audits an HTML string against on-page technical SEO best practices.
    public static func auditHTML(_ html: String, url: String = "https://example.com") -> AuditResult {
        return defaultAuditor.auditHTML(html, url: url)
    }

    /// Fetches a remote URL and audits the HTML markup (Async / Await).
    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    public static func auditURL(_ url: URL) async throws -> AuditResult {
        return try await defaultAuditor.auditURL(url)
    }

    /// Fetches a remote URL with completion callback.
    public static func auditURL(_ urlString: String, completion: @escaping @Sendable (Result<AuditResult, Error>) -> Void) {
        defaultAuditor.auditURL(urlString, completion: completion)
    }
}
