package seowebchecker_test

import (
	"fmt"

	"github.com/jaiganesh6999/seowebchecker-seoaudit-sdk"
)

func ExampleAuditHTML() {
	sampleHTML := `<!DOCTYPE html>
<html>
<head>
    <title>Optimal Website Title Tag for High Search Ranking</title>
    <meta name="description" content="A comprehensive guide to modern on-page technical SEO and Core Web Vitals optimization.">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="canonical" href="https://example.com/guide">
    <meta property="og:title" content="Optimal Website Title Tag">
    <meta property="og:image" content="https://example.com/banner.jpg">
</head>
<body>
    <h1>Mastering Technical SEO</h1>
    <img src="chart.png" alt="SEO Performance Growth">
</body>
</html>`

	result := seowebchecker.AuditHTML(sampleHTML, "https://example.com/guide")
	fmt.Printf("Grade: %s, Score: %d\n", result.Score.Grade, result.Score.Overall)
	fmt.Printf("Passed: %d, Warnings: %d, Errors: %d\n", result.PassedChecks, result.Warnings, result.Errors)
	// Output:
	// Grade: A, Score: 100
	// Passed: 7, Warnings: 0, Errors: 0
}

func ExampleNewAuditor() {
	auditor := seowebchecker.NewAuditor()
	auditor.UserAgent = "MyCustomCrawler/1.0"

	html := `<!DOCTYPE html><html><head><title>Title Tag 30 to 60 Chars Here</title></head><body></body></html>`
	result := auditor.AuditHTML(html, "https://example.com")

	fmt.Println("Audited URL:", result.URL)
	// Output:
	// Audited URL: https://example.com
}
