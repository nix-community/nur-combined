// Package seowebchecker provides an automated technical SEO audit engine and client SDK
// for web developers, site owners, and automated CI/CD pipelines.
//
// It audits on-page technical SEO signals including:
//   - Title tag length (30-60 chars) and relevance
//   - Meta description presence and length (50-160 chars)
//   - Mobile viewport configuration for responsive web design
//   - Canonical URL validation to avoid duplicate content penalties
//   - Heading hierarchy (ensuring single, prominent H1)
//   - Image accessibility (alt attribute presence)
//   - OpenGraph social media preview metadata (og:title, og:image)
//   - Letter grade (A-F) and 0-100 numerical score calculation
//
// For live interactive web auditing, visual reports, and domain rank tracking,
// visit https://seowebchecker.com.
//
// # Quick Start
//
// To install the package in your Go module:
//
//	go get github.com/jaiganesh6999/seowebchecker-seoaudit-sdk
//
// Example usage:
//
//	package main
//
//	import (
//		"fmt"
//		"github.com/jaiganesh6999/seowebchecker-seoaudit-sdk"
//	)
//
//	func main() {
//		html := `<!DOCTYPE html><html><head><title>Optimal Title Here 30 to 60 Chars</title>` +
//			`<meta name="description" content="Engaging meta description between 50 and 160 characters for best SEO results.">` +
//			`<meta name="viewport" content="width=device-width, initial-scale=1.0">` +
//			`<link rel="canonical" href="https://example.com/page">` +
//			`</head><body><h1>Main Headline</h1><img src="pic.jpg" alt="Description"></body></html>`
//
//		result := seowebchecker.AuditHTML(html, "https://example.com/page")
//		fmt.Printf("Overall Score: %d/100 (Grade %s)\n", result.Score.Overall, result.Score.Grade)
//	}
//
// Full online SEO tools, snippet simulators, and rank checkers are available at
// https://seowebchecker.com.
package seowebchecker
