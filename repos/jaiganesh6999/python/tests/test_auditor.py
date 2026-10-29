"""Unit tests for seowebchecker-seoaudit-sdk."""

import json
from seowebchecker_seoaudit.auditor import SEOAuditor
from seowebchecker_seoaudit.models import Severity, SeoScore
from seowebchecker_seoaudit.formatters import format_console, format_markdown, format_html


SAMPLE_GOOD_HTML = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SEOWebChecker: Free Website SEO Audit and Analysis Tool</title>
    <meta name="description" content="Audit your website with 50+ real-time SEO checks. Discover technical errors, optimize meta tags, and improve Google rankings instantly.">
    <link rel="canonical" href="https://seowebchecker.com/">
    <link rel="icon" href="/favicon.ico">
    <meta property="og:title" content="SEOWebChecker - Free SEO Audit Tool">
    <meta property="og:description" content="Discover technical errors and optimize on-page SEO.">
    <meta property="og:image" content="https://seowebchecker.com/og.png">
    <meta property="og:url" content="https://seowebchecker.com/">
    <meta name="twitter:card" content="summary_large_image">
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "WebApplication",
      "name": "SEOWebChecker",
      "url": "https://seowebchecker.com/"
    }
    </script>
</head>
<body>
    <h1>Free Online Website SEO Audit Tool</h1>
    <h2>Optimize Your Website for Search Engines</h2>
    <p>
        Welcome to SEOWebChecker, the premier open source and web-based SEO analyzer.
        Conduct in-depth audits covering meta tags, headings, content quality, page speed,
        Core Web Vitals, and mobile responsiveness in seconds.
        Search engine optimization is critical for driving organic traffic and growing online presence.
        Our tool verifies compliance with Google ranking factors, evaluates broken links,
        checks image alt text, and confirms proper canonicalization.
    </p>
    <h2>Comprehensive SEO Checks</h2>
    <p>
        Analyze your website hierarchy, internal link architecture, and security headers.
        Stay ahead of search algorithm changes with automated reporting and developer SDKs.
        Check out our documentation and test suite for continuous integration in deployment pipelines.
    </p>
    <a href="/features">Explore Features</a>
    <a href="https://github.com/seowebchecker" target="_blank" rel="noopener noreferrer">GitHub Project</a>
    <img src="https://seowebchecker.com/logo.webp" alt="SEOWebChecker Logo">
</body>
</html>"""


SAMPLE_POOR_HTML = """<html>
<head>
</head>
<body>
    <p>Hello world</p>
    <img src="test.jpg">
    <a href="https://external.com" target="_blank">click here</a>
</body>
</html>"""


def test_audit_good_html():
    auditor = SEOAuditor()
    headers = {
        "Strict-Transport-Security": "max-age=31536000",
        "X-Content-Type-Options": "nosniff",
        "Content-Encoding": "gzip",
    }
    result = auditor.audit_html(
        html=SAMPLE_GOOD_HTML,
        url="https://seowebchecker.com/",
        headers=headers,
        status_code=200,
        response_time_ms=180.0,
        robots_found=True,
        sitemap_found=True,
    )

    # Basic validations
    assert result.score.overall >= 85
    assert result.score.grade in ["A+", "A", "B"]
    assert result.meta.title == "SEOWebChecker: Free Website SEO Audit and Analysis Tool"
    assert result.meta.title_length > 30
    assert result.meta.canonical == "https://seowebchecker.com/"
    assert len(result.content.h1_tags) == 1
    assert len(result.content.h2_tags) == 2
    assert result.images.total_images == 1
    assert result.images.missing_alt == 0
    assert result.images.modern_formats_count == 1
    assert result.schema.has_schema is True
    assert "WebApplication" in result.schema.detected_types
    assert result.technical.is_https is True
    assert result.technical.hsts_enabled is True
    assert result.performance.is_compressed is True

    # JSON export
    json_str = result.to_json()
    data = json.loads(json_str)
    assert data["score"]["overall"] == result.score.overall
    assert data["stats"]["passed"] > 10

    # Markdown export
    md = format_markdown(result)
    assert "# SEO Audit Report" in md
    assert "SEOWebChecker" in md

    # HTML export
    html_rep = format_html(result)
    assert "<!DOCTYPE html>" in html_rep
    assert "SEOWebChecker" in html_rep

    # Console export
    console_out = format_console(result, use_color=False)
    assert "SEOWebChecker SEO Audit Report" in console_out


def test_audit_poor_html():
    auditor = SEOAuditor()
    result = auditor.audit_html(
        html=SAMPLE_POOR_HTML,
        url="http://insecure-example.com",
        headers={},
        status_code=200,
        response_time_ms=1200.0,
        robots_found=False,
        sitemap_found=False,
    )

    # Should detect errors
    assert result.score.overall < 70
    assert len(result.errors) > 0

    error_ids = [e.id for e in result.errors]
    assert "meta-title-missing" in error_ids
    assert "meta-desc-missing" in error_ids
    assert "meta-viewport-missing" in error_ids
    assert "content-h1-missing" in error_ids
    assert "tech-not-https" in error_ids
    assert "images-missing-alt" in error_ids


def test_grade_calculation():
    assert SeoScore.calculate_grade(98) == "A+"
    assert SeoScore.calculate_grade(91) == "A"
    assert SeoScore.calculate_grade(82) == "B"
    assert SeoScore.calculate_grade(74) == "C"
    assert SeoScore.calculate_grade(65) == "D"
    assert SeoScore.calculate_grade(45) == "F"


if __name__ == "__main__":
    test_audit_good_html()
    test_audit_poor_html()
    test_grade_calculation()
    print("All unit tests passed successfully!")
