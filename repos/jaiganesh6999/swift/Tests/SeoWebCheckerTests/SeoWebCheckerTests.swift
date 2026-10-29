import XCTest
@testable import SeoWebChecker

final class SeoWebCheckerTests: XCTestCase {
    func testOptimalHTMLReturns100AndGradeA() {
        let html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <title>Optimal Website Title Tag for High Search Ranking</title>
            <meta name="description" content="A comprehensive guide to modern on-page technical SEO and Core Web Vitals optimization.">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <link rel="canonical" href="https://example.com/guide">
            <meta property="og:title" content="Optimal Title">
            <meta property="og:image" content="https://example.com/og.jpg">
        </head>
        <body>
            <h1>Mastering Technical SEO</h1>
            <img src="chart.png" alt="SEO Traffic Chart">
        </body>
        </html>
        """

        let result = SeoWebChecker.auditHTML(html, url: "https://example.com/guide")
        XCTAssertEqual(result.score.overall, 100)
        XCTAssertEqual(result.score.grade, "A")
        XCTAssertEqual(result.errors, 0)
        XCTAssertEqual(result.warnings, 0)
        XCTAssertEqual(result.metadata["title"], "Optimal Website Title Tag for High Search Ranking")
        XCTAssertEqual(result.metadata["h1"], "Mastering Technical SEO")
    }

    func testDefectiveHTMLReportsErrors() {
        let html = """
        <!DOCTYPE html>
        <html>
        <head></head>
        <body>
            <div>Missing title, description, viewport, canonical, and h1.</div>
            <img src="pic.jpg">
        </body>
        </html>
        """

        let result = SeoWebChecker.auditHTML(html, url: "https://example.com/bad")
        XCTAssertLessThan(result.score.overall, 60)
        XCTAssertGreaterThanOrEqual(result.errors, 3)

        let issueIds = Set(result.issues.map { $0.id })
        XCTAssertTrue(issueIds.contains("meta-title-missing"))
        XCTAssertTrue(issueIds.contains("meta-desc-missing"))
        XCTAssertTrue(issueIds.contains("h1-missing"))
        XCTAssertTrue(issueIds.contains("img-alt-missing"))
    }
}
