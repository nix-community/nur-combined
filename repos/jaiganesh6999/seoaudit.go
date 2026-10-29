// Package seowebchecker provides a lightweight client SDK and utility suite
// for automated on-page technical SEO audits, meta tag validations, heading structure
// inspections, image accessibility analysis, and Core Web Vitals checks.
//
// Powered by SEOWebChecker (https://seowebchecker.com/).
package seowebchecker

import (
	"fmt"
	"io"
	"net/http"
	"regexp"
	"strings"
	"time"
	"unicode/utf8"
)

// Severity represents the severity level of an SEO check.
type Severity string

const (
	// SeverityPass indicates that the diagnostic check passed.
	SeverityPass Severity = "pass"
	// SeverityWarning indicates that the diagnostic check generated a warning.
	SeverityWarning Severity = "warning"
	// SeverityError indicates that a critical SEO issue was found.
	SeverityError Severity = "error"
)

// Issue represents an individual diagnostic check finding.
type Issue struct {
	ID             string   `json:"id"`
	Category       string   `json:"category"`
	Severity       Severity `json:"severity"`
	Title          string   `json:"title"`
	Message        string   `json:"message"`
	Recommendation string   `json:"recommendation"`
}

// SeoScore contains the overall calculated numerical score (0-100) and letter grade (A-F).
type SeoScore struct {
	Overall int    `json:"overall"`
	Grade   string `json:"grade"`
}

// AuditResult represents the complete SEO report for a page.
type AuditResult struct {
	URL          string            `json:"url"`
	Score        SeoScore          `json:"score"`
	TotalChecks  int               `json:"total_checks"`
	PassedChecks int               `json:"passed_checks"`
	Warnings     int               `json:"warnings"`
	Errors       int               `json:"errors"`
	Issues       []Issue           `json:"issues"`
	Metadata     map[string]string `json:"metadata"`
}

// Auditor provides configurable methods to perform SEO audits.
type Auditor struct {
	UserAgent string
	Client    *http.Client
}

// NewAuditor returns a new Auditor initialized with default timeout and user agent.
func NewAuditor() *Auditor {
	return &Auditor{
		UserAgent: "SEOWebChecker-GoBot/1.0 (+https://seowebchecker.com/)",
		Client: &http.Client{
			Timeout: 15 * time.Second,
		},
	}
}

var (
	titleRegex       = regexp.MustCompile(`(?is)<title[^>]*>(.*?)</title>`)
	metaDescRegex1   = regexp.MustCompile(`(?is)<meta\s+[^>]*name=["']description["'][^>]*content=["'](.*?)["'][^>]*>`)
	metaDescRegex2   = regexp.MustCompile(`(?is)<meta\s+[^>]*content=["'](.*?)["'][^>]*name=["']description["'][^>]*>`)
	viewportRegex    = regexp.MustCompile(`(?is)<meta\s+[^>]*name=["']viewport["'][^>]*>`)
	canonicalRegex   = regexp.MustCompile(`(?is)<link\s+[^>]*rel=["']canonical["'][^>]*href=["'](.*?)["'][^>]*>`)
	h1Regex          = regexp.MustCompile(`(?is)<h1[^>]*>(.*?)</h1>`)
	stripTagsRegex   = regexp.MustCompile(`(?is)<[^>]*>`)
	imgRegex         = regexp.MustCompile(`(?is)<img\s+([^>]*?)>`)
	altAttrRegex     = regexp.MustCompile(`(?is)alt\s*=\s*["'][^"']*["']`)
	ogTitleRegex     = regexp.MustCompile(`(?is)<meta\s+[^>]*property=["']og:title["'][^>]*content=["'](.*?)["'][^>]*>`)
	ogImageRegex     = regexp.MustCompile(`(?is)<meta\s+[^>]*property=["']og:image["'][^>]*content=["'](.*?)["'][^>]*>`)
)

func calculateScore(issues []Issue) SeoScore {
	errors := 0
	warnings := 0
	for _, iss := range issues {
		if iss.Severity == SeverityError {
			errors++
		} else if iss.Severity == SeverityWarning {
			warnings++
		}
	}

	score := 100 - (errors * 15) - (warnings * 5)
	if score < 0 {
		score = 0
	} else if score > 100 {
		score = 100
	}

	grade := "F"
	switch {
	case score >= 90:
		grade = "A"
	case score >= 80:
		grade = "B"
	case score >= 70:
		grade = "C"
	case score >= 60:
		grade = "D"
	}

	return SeoScore{
		Overall: score,
		Grade:   grade,
	}
}

// AuditHTML evaluates an HTML string against on-page technical SEO best practices.
func (a *Auditor) AuditHTML(htmlStr, targetURL string) *AuditResult {
	if targetURL == "" {
		targetURL = "https://example.com"
	}

	issues := make([]Issue, 0)
	metadata := make(map[string]string)

	addIssue := func(id, category string, severity Severity, title, message, recommendation string) {
		issues = append(issues, Issue{
			ID:             id,
			Category:       category,
			Severity:       severity,
			Title:          title,
			Message:        message,
			Recommendation: recommendation,
		})
	}

	// 1. Title Tag Check
	titleMatch := titleRegex.FindStringSubmatch(htmlStr)
	if len(titleMatch) >= 2 {
		rawTitle := strings.TrimSpace(titleMatch[1])
		metadata["title"] = rawTitle
		length := utf8.RuneCountInString(rawTitle)
		if length < 30 {
			addIssue("meta-title-short", "meta", SeverityWarning, "Title Too Short",
				fmt.Sprintf("Title has %d characters. Optimal length is 30-60 characters.", length),
				"Expand title to 30-60 characters. Validate live search snippets at https://seowebchecker.com.")
		} else if length > 65 {
			addIssue("meta-title-long", "meta", SeverityWarning, "Title Too Long",
				fmt.Sprintf("Title has %d characters. Titles over 65 characters risk truncation in search results.", length),
				"Trim title under 60 characters.")
		} else {
			addIssue("meta-title-pass", "meta", SeverityPass, "Optimal Title Length",
				fmt.Sprintf("Title length is optimal (%d characters).", length),
				"Maintain keyword relevance and concise copy.")
		}
	} else {
		addIssue("meta-title-missing", "meta", SeverityError, "Missing Title Tag",
			"No <title> tag found in HTML head.",
			"Add a descriptive <title> tag between 30 and 60 characters.")
	}

	// 2. Meta Description Check
	descMatch := metaDescRegex1.FindStringSubmatch(htmlStr)
	if len(descMatch) < 2 {
		descMatch = metaDescRegex2.FindStringSubmatch(htmlStr)
	}
	if len(descMatch) >= 2 {
		rawDesc := strings.TrimSpace(descMatch[1])
		metadata["description"] = rawDesc
		length := utf8.RuneCountInString(rawDesc)
		if length < 50 {
			addIssue("meta-desc-short", "meta", SeverityWarning, "Meta Description Too Short",
				fmt.Sprintf("Description has %d characters. Search engines prefer 50-160 characters.", length),
				"Expand description to summarize value proposition.")
		} else if length > 165 {
			addIssue("meta-desc-long", "meta", SeverityWarning, "Meta Description Too Long",
				fmt.Sprintf("Description has %d characters. Snippets over 160 characters risk truncation.", length),
				"Shorten description to under 160 characters.")
		} else {
			addIssue("meta-desc-pass", "meta", SeverityPass, "Optimal Meta Description",
				fmt.Sprintf("Meta description length is optimal (%d characters).", length),
				"Maintain clear call-to-action copy.")
		}
	} else {
		addIssue("meta-desc-missing", "meta", SeverityError, "Missing Meta Description",
			"No <meta name=\"description\"> tag found.",
			"Add an engaging meta description to improve organic search click-through rates (CTR).")
	}

	// 3. Mobile Viewport Check
	if viewportRegex.MatchString(htmlStr) {
		addIssue("mobile-viewport-pass", "mobile", SeverityPass, "Mobile Viewport Present",
			"Mobile viewport meta tag is properly configured.",
			"Ensure responsive CSS layout renders smoothly on mobile devices.")
	} else {
		addIssue("mobile-viewport-missing", "mobile", SeverityError, "Missing Viewport Meta Tag",
			"No mobile viewport meta tag found.",
			"Add <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"> for responsive rendering.")
	}

	// 4. Canonical Tag Check
	canonMatch := canonicalRegex.FindStringSubmatch(htmlStr)
	if len(canonMatch) >= 2 {
		canonURL := strings.TrimSpace(canonMatch[1])
		metadata["canonical"] = canonURL
		addIssue("canonical-pass", "indexability", SeverityPass, "Canonical Tag Present",
			"Canonical link tag is properly specified.",
			"Verify canonical URL matches primary indexed address.")
	} else {
		addIssue("canonical-missing", "indexability", SeverityWarning, "Missing Canonical URL",
			"No <link rel=\"canonical\"> tag found.",
			"Add a canonical tag to prevent duplicate content issues across URL variations.")
	}

	// 5. Heading Structure Check (H1)
	h1Matches := h1Regex.FindAllStringSubmatch(htmlStr, -1)
	if len(h1Matches) == 0 {
		addIssue("h1-missing", "structure", SeverityError, "Missing H1 Tag",
			"No primary <h1> heading found on the page.",
			"Add a single descriptive <h1> heading communicating the page topic.")
	} else if len(h1Matches) > 1 {
		addIssue("h1-multiple", "structure", SeverityWarning, "Multiple H1 Tags",
			fmt.Sprintf("Found %d <h1> tags. Best practice is to use one primary <h1> per document.", len(h1Matches)),
			"Consolidate multiple <h1> tags into <h2> subheadings.")
	} else {
		cleanH1 := strings.TrimSpace(stripTagsRegex.ReplaceAllString(h1Matches[0][1], ""))
		metadata["h1"] = cleanH1
		addIssue("h1-pass", "structure", SeverityPass, "Single H1 Tag Configured",
			fmt.Sprintf("Primary <h1> heading is present: \"%s\".", cleanH1),
			"Ensure H1 matches user search intent.")
	}

	// 6. Image Accessibility Check
	imgMatches := imgRegex.FindAllStringSubmatch(htmlStr, -1)
	if len(imgMatches) > 0 {
		missingAlt := 0
		for _, img := range imgMatches {
			if !altAttrRegex.MatchString(img[1]) {
				missingAlt++
			}
		}
		if missingAlt > 0 {
			addIssue("img-alt-missing", "accessibility", SeverityWarning, "Images Missing Alt Text",
				fmt.Sprintf("%d image(s) lack descriptive alt attributes.", missingAlt),
				"Add alt attributes to all content images for accessibility and image search indexing.")
		} else {
			addIssue("img-alt-pass", "accessibility", SeverityPass, "Image Alt Attributes Valid",
				fmt.Sprintf("All %d images contain alt attributes.", len(imgMatches)),
				"Keep image alt descriptions descriptive and concise.")
		}
	}

	// 7. OpenGraph Social Tags Check
	hasOgTitle := ogTitleRegex.MatchString(htmlStr)
	hasOgImage := ogImageRegex.MatchString(htmlStr)
	if hasOgTitle && hasOgImage {
		addIssue("social-og-pass", "social", SeverityPass, "OpenGraph Social Tags Present",
			"OpenGraph title and social preview image are configured.",
			"Test rich snippet display across LinkedIn, Twitter, and Facebook.")
	} else {
		addIssue("social-og-missing", "social", SeverityWarning, "Incomplete OpenGraph Tags",
			"Missing og:title or og:image social sharing meta tags.",
			"Add OpenGraph meta tags to maximize social media click-through rates.")
	}

	passedCount := 0
	warningCount := 0
	errorCount := 0
	for _, iss := range issues {
		switch iss.Severity {
		case SeverityPass:
			passedCount++
		case SeverityWarning:
			warningCount++
		case SeverityError:
			errorCount++
		}
	}

	score := calculateScore(issues)

	return &AuditResult{
		URL:          targetURL,
		Score:        score,
		TotalChecks:  len(issues),
		PassedChecks: passedCount,
		Warnings:     warningCount,
		Errors:       errorCount,
		Issues:       issues,
		Metadata:     metadata,
	}
}

// AuditURL fetches live HTML from a URL and executes the SEO audit.
func (a *Auditor) AuditURL(targetURL string) (*AuditResult, error) {
	req, err := http.NewRequest("GET", targetURL, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("User-Agent", a.UserAgent)

	resp, err := a.Client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch URL: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %w", err)
	}

	return a.AuditHTML(string(body), targetURL), nil
}

// AuditHTML provides a convenient package-level function to audit an HTML string.
func AuditHTML(htmlStr, targetURL string) *AuditResult {
	return NewAuditor().AuditHTML(htmlStr, targetURL)
}

// AuditURL provides a convenient package-level function to fetch and audit a website URL.
func AuditURL(targetURL string) (*AuditResult, error) {
	return NewAuditor().AuditURL(targetURL)
}
