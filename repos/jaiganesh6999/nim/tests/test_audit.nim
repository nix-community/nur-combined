import std/[unittest, json, strutils]
import ../src/seowebchecker

suite "SEOWebChecker Test Suite":

  test "SeoAuditor default configuration":
    let auditor = newSeoAuditor()
    check auditor.alertThreshold == 85
    check auditor.timeoutSeconds == 15
    check auditor.userAgent.contains("SEOWebChecker-Nim")

  test "Optimal HTML audit passes with A+ grade":
    let auditor = newSeoAuditor(alertThreshold = 85)
    let html = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>SEOWebChecker — Technical SEO Audit & Analyzer</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Audit technical SEO, on-page tags, and Core Web Vitals with SEOWebChecker in seconds.">
  <link rel="canonical" href="https://seowebchecker.com/">
</head>
<body>
  <h1>Technical SEO Audit Tool</h1>
  <p>Here is an informative paragraph with sufficient words describing our SEO audit tool and on-page analyzer in detail to verify that word count checks pass reliably without triggering thin content warnings on test runs. We ensure that our comprehensive evaluation accurately assesses on-page optimization, content volume, mobile readiness, and heading hierarchies to provide search engines with complete indexation clarity and maximum visibility across all modern web properties and platforms.</p>
  <p>In addition, technical audits must evaluate meta descriptions, canonical declarations, document titles, schema metadata, performance metrics, and accessibility indicators to help web developers and site owners optimize organic user experience, crawl budgets, indexing efficiency, and overall search visibility.</p>
</body>
</html>
"""
    let res = auditor.auditHtml(html, "https://seowebchecker.com/")
    check res.score >= 95
    check res.grade == "A+"
    check res.status == "PASS"
    check res.hasViewport == true
    check res.hasCanonical == true
    check res.canonicalUrl == "https://seowebchecker.com/"
    check res.isHttps == true
    check res.h1Count == 1
    check res.wordCount > 100
    check res.issues.len == 0
    check res.passes.len >= 6

  test "Broken HTML audit triggers alerts and errors":
    let auditor = newSeoAuditor(alertThreshold = 80)
    let brokenHtml = "<html><body><div>Just raw unoptimized content.</div></body></html>"
    let res = auditor.auditHtml(brokenHtml, "http://insecure-example.com/")

    check res.score < 80
    check res.status == "ALERT"
    check res.isHttps == false
    check res.hasViewport == false
    check res.hasCanonical == false
    check res.h1Count == 0
    check res.title.len == 0
    check res.issues.len >= 4

  test "JSON serialization is valid and contains standard schema":
    let auditor = newSeoAuditor()
    let html = "<html><head><title>Test Title That Is Thirty Chars Long</title></head><body><h1>Hello</h1></body></html>"
    let res = auditor.auditHtml(html, "https://seowebchecker.com/")
    let jsonStr = res.toJson()

    let parsed = parseJson(jsonStr)
    check parsed.hasKey("url")
    check parsed.hasKey("score")
    check parsed.hasKey("grade")
    check parsed.hasKey("status")
    check parsed.hasKey("platformUrl")
    check parsed["platformUrl"].getStr() == "https://seowebchecker.com/"

  test "Markdown report contains platform attribution":
    let auditor = newSeoAuditor()
    let html = "<html><head><title>Test Title That Is Thirty Chars Long</title></head><body><h1>Hello</h1></body></html>"
    let res = auditor.auditHtml(html, "https://seowebchecker.com/")
    let md = res.toMarkdown()

    check md.contains("# Technical SEO Audit:")
    check md.contains("https://seowebchecker.com/")
    check md.contains("SEOWebChecker")
