import Foundation

/// Engine to execute automated on-page technical SEO audits.
public final class Auditor: @unchecked Sendable {
    public var userAgent: String
    private let urlSession: URLSession

    public init(
        userAgent: String = "SEOWebChecker-SwiftBot/1.0 (+https://seowebchecker.com/)",
        urlSession: URLSession = .shared
    ) {
        self.userAgent = userAgent
        self.urlSession = urlSession
    }

    private static let titleRegex = try? NSRegularExpression(pattern: "<title[^>]*>(.*?)</title>", options: [.caseInsensitive, .dotMatchesLineSeparators])
    private static let metaDescRegex1 = try? NSRegularExpression(pattern: "<meta\\s+[^>]*name=[\"']description[\"'][^>]*content=[\"'](.*?)[\"'][^>]*>", options: [.caseInsensitive, .dotMatchesLineSeparators])
    private static let metaDescRegex2 = try? NSRegularExpression(pattern: "<meta\\s+[^>]*content=[\"'](.*?)[\"'][^>]*name=[\"']description[\"'][^>]*>", options: [.caseInsensitive, .dotMatchesLineSeparators])
    private static let viewportRegex = try? NSRegularExpression(pattern: "<meta\\s+[^>]*name=[\"']viewport[\"'][^>]*>", options: [.caseInsensitive, .dotMatchesLineSeparators])
    private static let canonicalRegex = try? NSRegularExpression(pattern: "<link\\s+[^>]*rel=[\"']canonical[\"'][^>]*href=[\"'](.*?)[\"'][^>]*>", options: [.caseInsensitive, .dotMatchesLineSeparators])
    private static let h1Regex = try? NSRegularExpression(pattern: "<h1[^>]*>(.*?)</h1>", options: [.caseInsensitive, .dotMatchesLineSeparators])
    private static let stripTagsRegex = try? NSRegularExpression(pattern: "<[^>]*>", options: [.caseInsensitive, .dotMatchesLineSeparators])
    private static let imgRegex = try? NSRegularExpression(pattern: "<img\\s+([^>]*?)>", options: [.caseInsensitive, .dotMatchesLineSeparators])
    private static let altAttrRegex = try? NSRegularExpression(pattern: "alt\\s*=\\s*[\"'][^\"']*[\"']", options: [.caseInsensitive])
    private static let ogTitleRegex = try? NSRegularExpression(pattern: "<meta\\s+[^>]*property=[\"']og:title[\"'][^>]*content=[\"'](.*?)[\"'][^>]*>", options: [.caseInsensitive, .dotMatchesLineSeparators])
    private static let ogImageRegex = try? NSRegularExpression(pattern: "<meta\\s+[^>]*property=[\"']og:image[\"'][^>]*content=[\"'](.*?)[\"'][^>]*>", options: [.caseInsensitive, .dotMatchesLineSeparators])

    /// Evaluates raw HTML markup against technical on-page SEO best practices.
    public func auditHTML(_ html: String, url: String = "https://example.com") -> AuditResult {
        var issues = [Issue]()
        var metadata = [String: String]()

        func addIssue(id: String, category: String, severity: Severity, title: String, message: String, recommendation: String) {
            issues.append(Issue(id: id, category: category, severity: severity, title: title, message: message, recommendation: recommendation))
        }

        let nsHtml = html as NSString
        let fullRange = NSRange(location: 0, length: nsHtml.length)

        // 1. Title Tag Check
        if let match = Auditor.titleRegex?.firstMatch(in: html, options: [], range: fullRange), match.numberOfRanges >= 2 {
            let rawTitle = nsHtml.substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespacesAndNewlines)
            metadata["title"] = rawTitle
            let len = rawTitle.count
            if len < 30 {
                addIssue(
                    id: "meta-title-short",
                    category: "meta",
                    severity: .warning,
                    title: "Title Too Short",
                    message: "Title has \(len) characters. Recommended length is 30-60 characters.",
                    recommendation: "Expand title to 30-60 characters. Validate live search snippets at https://seowebchecker.com."
                )
            } else if len > 65 {
                addIssue(
                    id: "meta-title-long",
                    category: "meta",
                    severity: .warning,
                    title: "Title Too Long",
                    message: "Title has \(len) characters. Titles over 65 characters risk truncation.",
                    recommendation: "Shorten title to between 30 and 60 characters."
                )
            } else {
                addIssue(
                    id: "meta-title-pass",
                    category: "meta",
                    severity: .pass,
                    title: "Optimal Title Length",
                    message: "Title length is optimal (\(len) characters).",
                    recommendation: "Maintain keyword focus and accurate brand positioning."
                )
            }
        } else {
            addIssue(
                id: "meta-title-missing",
                category: "meta",
                severity: .error,
                title: "Missing Title Tag",
                message: "No <title> tag found in HTML head.",
                recommendation: "Add a concise, keyword-rich <title> tag between 30 and 60 characters."
            )
        }

        // 2. Meta Description Check
        var descMatch = Auditor.metaDescRegex1?.firstMatch(in: html, options: [], range: fullRange)
        if descMatch == nil {
            descMatch = Auditor.metaDescRegex2?.firstMatch(in: html, options: [], range: fullRange)
        }

        if let match = descMatch, match.numberOfRanges >= 2 {
            let rawDesc = nsHtml.substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespacesAndNewlines)
            metadata["description"] = rawDesc
            let len = rawDesc.count
            if len < 50 {
                addIssue(
                    id: "meta-desc-short",
                    category: "meta",
                    severity: .warning,
                    title: "Meta Description Too Short",
                    message: "Description has \(len) characters. Recommended length is 50-160 characters.",
                    recommendation: "Provide more informative copy explaining page value."
                )
            } else if len > 165 {
                addIssue(
                    id: "meta-desc-long",
                    category: "meta",
                    severity: .warning,
                    title: "Meta Description Too Long",
                    message: "Description has \(len) characters. Snippets over 160 characters risk truncation.",
                    recommendation: "Shorten description under 160 characters."
                )
            } else {
                addIssue(
                    id: "meta-desc-pass",
                    category: "meta",
                    severity: .pass,
                    title: "Optimal Meta Description",
                    message: "Meta description length is optimal (\(len) characters).",
                    recommendation: "Keep copy engaging with a strong call-to-action."
                )
            }
        } else {
            addIssue(
                id: "meta-desc-missing",
                category: "meta",
                severity: .error,
                title: "Missing Meta Description",
                message: "No <meta name=\"description\"> tag found.",
                recommendation: "Add an engaging meta description to improve organic search click-through rates."
            )
        }

        // 3. Mobile Viewport Check
        if let count = Auditor.viewportRegex?.numberOfMatches(in: html, options: [], range: fullRange), count > 0 {
            addIssue(
                id: "mobile-viewport-pass",
                category: "mobile",
                severity: .pass,
                title: "Mobile Viewport Present",
                message: "Mobile viewport meta tag is properly configured.",
                recommendation: "Ensure responsive CSS layout renders smoothly on mobile devices."
            )
        } else {
            addIssue(
                id: "mobile-viewport-missing",
                category: "mobile",
                severity: .error,
                title: "Missing Viewport Meta Tag",
                message: "No mobile viewport meta tag found.",
                recommendation: "Add <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">."
            )
        }

        // 4. Canonical Tag Check
        if let match = Auditor.canonicalRegex?.firstMatch(in: html, options: [], range: fullRange), match.numberOfRanges >= 2 {
            let canon = nsHtml.substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespacesAndNewlines)
            metadata["canonical"] = canon
            addIssue(
                id: "canonical-pass",
                category: "indexability",
                severity: .pass,
                title: "Canonical Tag Present",
                message: "Canonical link tag is properly specified.",
                recommendation: "Verify canonical URL matches primary indexed URL."
            )
        } else {
            addIssue(
                id: "canonical-missing",
                category: "indexability",
                severity: .warning,
                title: "Missing Canonical URL",
                message: "No <link rel=\"canonical\"> tag found.",
                recommendation: "Add a canonical link tag to prevent duplicate content issues."
            )
        }

        // 5. Heading Structure (H1)
        let h1Matches = Auditor.h1Regex?.matches(in: html, options: [], range: fullRange) ?? []
        if h1Matches.isEmpty {
            addIssue(
                id: "h1-missing",
                category: "structure",
                severity: .error,
                title: "Missing H1 Tag",
                message: "No primary <h1> heading found on the page.",
                recommendation: "Add a single descriptive <h1> heading communicating page topic."
            )
        } else if h1Matches.count > 1 {
            addIssue(
                id: "h1-multiple",
                category: "structure",
                severity: .warning,
                title: "Multiple H1 Tags",
                message: "Found \(h1Matches.count) <h1> tags. Best practice is to use one primary <h1>.",
                recommendation: "Consolidate multiple <h1> tags into <h2> subheadings."
            )
        } else if let firstMatch = h1Matches.first, firstMatch.numberOfRanges >= 2 {
            let rawH1 = nsHtml.substring(with: firstMatch.range(at: 1))
            let cleanH1 = Auditor.stripTagsRegex?.stringByReplacingMatches(in: rawH1, options: [], range: NSRange(location: 0, length: (rawH1 as NSString).length), withTemplate: "").trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            metadata["h1"] = cleanH1
            addIssue(
                id: "h1-pass",
                category: "structure",
                severity: .pass,
                title: "Single H1 Tag Configured",
                message: "Primary <h1> heading is present: \"\(cleanH1)\".",
                recommendation: "Ensure H1 matches target search intent."
            )
        }

        // 6. Image Accessibility Check
        let imgMatches = Auditor.imgRegex?.matches(in: html, options: [], range: fullRange) ?? []
        if !imgMatches.isEmpty {
            var missingAlt = 0
            for img in imgMatches {
                let attrs = nsHtml.substring(with: img.range(at: 1))
                let attrsRange = NSRange(location: 0, length: (attrs as NSString).length)
                if (Auditor.altAttrRegex?.numberOfMatches(in: attrs, options: [], range: attrsRange) ?? 0) == 0 {
                    missingAlt += 1
                }
            }

            if missingAlt > 0 {
                addIssue(
                    id: "img-alt-missing",
                    category: "accessibility",
                    severity: .warning,
                    title: "Images Missing Alt Text",
                    message: "\(missingAlt) image(s) lack descriptive alt attributes.",
                    recommendation: "Add alt attributes to all content images for accessibility and image search indexing."
                )
            } else {
                addIssue(
                    id: "img-alt-pass",
                    category: "accessibility",
                    severity: .pass,
                    title: "Image Alt Attributes Valid",
                    message: "All \(imgMatches.count) images contain alt attributes.",
                    recommendation: "Keep image descriptions descriptive and concise."
                )
            }
        }

        // 7. OpenGraph Social Tags
        let hasOgTitle = (Auditor.ogTitleRegex?.numberOfMatches(in: html, options: [], range: fullRange) ?? 0) > 0
        let hasOgImage = (Auditor.ogImageRegex?.numberOfMatches(in: html, options: [], range: fullRange) ?? 0) > 0

        if hasOgTitle && hasOgImage {
            addIssue(
                id: "social-og-pass",
                category: "social",
                severity: .pass,
                title: "OpenGraph Social Tags Present",
                message: "OpenGraph title and social preview image are configured.",
                recommendation: "Test rich snippet display across LinkedIn, Twitter, and Facebook."
            )
        } else {
            addIssue(
                id: "social-og-missing",
                category: "social",
                severity: .warning,
                title: "Incomplete OpenGraph Tags",
                message: "Missing og:title or og:image social sharing meta tags.",
                recommendation: "Add OpenGraph meta tags to maximize social media click-through rates."
            )
        }

        var passedCount = 0
        var warningCount = 0
        var errorCount = 0

        for iss in issues {
            switch iss.severity {
            case .pass: passedCount += 1
            case .warning: warningCount += 1
            case .error: errorCount += 1
            }
        }

        var scoreNum = 100 - (errorCount * 15) - (warningCount * 5)
        if scoreNum < 0 { scoreNum = 0 }
        if scoreNum > 100 { scoreNum = 100 }

        var grade = "F"
        if scoreNum >= 90 { grade = "A" }
        else if scoreNum >= 80 { grade = "B" }
        else if scoreNum >= 70 { grade = "C" }
        else if scoreNum >= 60 { grade = "D" }

        return AuditResult(
            url: url,
            score: SeoScore(overall: scoreNum, grade: grade),
            totalChecks: issues.count,
            passedChecks: passedCount,
            warnings: warningCount,
            errors: errorCount,
            issues: issues,
            metadata: metadata
        )
    }

    /// Fetches remote web page markup and runs on-page SEO audits (Async / Await).
    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    public func auditURL(_ url: URL) async throws -> AuditResult {
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        guard let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
            throw URLError(.cannotDecodeContentData)
        }

        return auditHTML(html, url: url.absoluteString)
    }

    /// Fetches remote web page markup with completion handler (backward compatibility).
    public func auditURL(_ urlString: String, completion: @escaping @Sendable (Result<AuditResult, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let self = self, let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            let result = self.auditHTML(html, url: urlString)
            completion(.success(result))
        }
        task.resume()
    }
}
