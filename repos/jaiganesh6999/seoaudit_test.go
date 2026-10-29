package seowebchecker

import (
	"strings"
	"testing"
)

func TestAuditHTML_PerfectPage(t *testing.T) {
	html := `<!DOCTYPE html>
<html lang="en">
<head>
    <title>Optimal Website Title Tag for High Search Ranking</title>
    <meta name="description" content="A comprehensive guide to modern on-page technical SEO, Core Web Vitals optimization, and keyword performance tracking.">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="canonical" href="https://example.com/perfect-page">
    <meta property="og:title" content="Optimal Website Title Tag">
    <meta property="og:image" content="https://example.com/og.jpg">
</head>
<body>
    <h1>Mastering Technical SEO for 2026</h1>
    <p>Welcome to our comprehensive technical SEO checklist.</p>
    <img src="chart.png" alt="SEO Performance Growth Chart">
</body>
</html>`

	result := AuditHTML(html, "https://example.com/perfect-page")
	if result == nil {
		t.Fatal("expected non-nil AuditResult")
	}

	if result.Score.Overall != 100 {
		t.Errorf("expected score 100, got %d", result.Score.Overall)
	}

	if result.Score.Grade != "A" {
		t.Errorf("expected grade A, got %s", result.Score.Grade)
	}

	if result.Errors != 0 {
		t.Errorf("expected 0 errors, got %d", result.Errors)
	}

	if result.Warnings != 0 {
		t.Errorf("expected 0 warnings, got %d", result.Warnings)
	}

	if result.Metadata["title"] != "Optimal Website Title Tag for High Search Ranking" {
		t.Errorf("unexpected title metadata: %s", result.Metadata["title"])
	}

	if result.Metadata["h1"] != "Mastering Technical SEO for 2026" {
		t.Errorf("unexpected H1 metadata: %s", result.Metadata["h1"])
	}
}

func TestAuditHTML_MissingElements(t *testing.T) {
	html := `<!DOCTYPE html>
<html>
<head></head>
<body>
    <div>No title, no meta description, no viewport, no canonical, no h1</div>
    <img src="no-alt.jpg">
</body>
</html>`

	result := AuditHTML(html, "https://example.com/bad-page")
	if result == nil {
		t.Fatal("expected non-nil AuditResult")
	}

	if result.Score.Overall >= 60 {
		t.Errorf("expected score < 60 for defective page, got %d", result.Score.Overall)
	}

	if result.Errors < 3 {
		t.Errorf("expected at least 3 errors, got %d", result.Errors)
	}

	hasMissingTitle := false
	hasMissingDesc := false
	hasMissingH1 := false
	hasMissingAlt := false

	for _, iss := range result.Issues {
		switch iss.ID {
		case "meta-title-missing":
			hasMissingTitle = true
		case "meta-desc-missing":
			hasMissingDesc = true
		case "h1-missing":
			hasMissingH1 = true
		case "img-alt-missing":
			hasMissingAlt = true
		}
	}

	if !hasMissingTitle {
		t.Error("expected meta-title-missing issue")
	}
	if !hasMissingDesc {
		t.Error("expected meta-desc-missing issue")
	}
	if !hasMissingH1 {
		t.Error("expected h1-missing issue")
	}
	if !hasMissingAlt {
		t.Error("expected img-alt-missing issue")
	}
}

func TestAuditHTML_ShortAndLongLengths(t *testing.T) {
	shortHTML := `<!DOCTYPE html><html><head>
<title>Short</title>
<meta name="description" content="Too short">
<meta name="viewport" content="width=device-width">
<link rel="canonical" href="https://example.com">
</head><body><h1>Heading</h1></body></html>`

	resShort := AuditHTML(shortHTML, "https://example.com")
	foundShortTitle := false
	foundShortDesc := false
	for _, iss := range resShort.Issues {
		if iss.ID == "meta-title-short" {
			foundShortTitle = true
		}
		if iss.ID == "meta-desc-short" {
			foundShortDesc = true
		}
	}
	if !foundShortTitle {
		t.Error("expected meta-title-short warning")
	}
	if !foundShortDesc {
		t.Error("expected meta-desc-short warning")
	}

	longHTML := `<!DOCTYPE html><html><head>
<title>` + strings.Repeat("A", 80) + `</title>
<meta name="description" content="` + strings.Repeat("B", 200) + `">
<meta name="viewport" content="width=device-width">
<link rel="canonical" href="https://example.com">
</head><body><h1>Heading</h1></body></html>`

	resLong := AuditHTML(longHTML, "https://example.com")
	foundLongTitle := false
	foundLongDesc := false
	for _, iss := range resLong.Issues {
		if iss.ID == "meta-title-long" {
			foundLongTitle = true
		}
		if iss.ID == "meta-desc-long" {
			foundLongDesc = true
		}
	}
	if !foundLongTitle {
		t.Error("expected meta-title-long warning")
	}
	if !foundLongDesc {
		t.Error("expected meta-desc-long warning")
	}
}

func TestAuditHTML_MultipleH1(t *testing.T) {
	html := `<!DOCTYPE html><html><head>
<title>Valid Title With Proper Character Count Here</title>
<meta name="description" content="Valid description length with sufficient keywords and call to action text.">
<meta name="viewport" content="width=device-width">
</head><body>
<h1>First H1</h1>
<h1>Second H1</h1>
</body></html>`

	res := AuditHTML(html, "https://example.com")
	foundMultipleH1 := false
	for _, iss := range res.Issues {
		if iss.ID == "h1-multiple" {
			foundMultipleH1 = true
		}
	}
	if !foundMultipleH1 {
		t.Error("expected h1-multiple warning")
	}
}
