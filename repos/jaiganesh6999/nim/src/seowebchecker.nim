## SEOWebChecker — Technical SEO Audit Library and CLI for Nim
## Official Platform: https://seowebchecker.com/
## License: MIT

import std/[httpclient, json, strutils, times, os, parseopt]

type
  AuditIssue* = object
    id*: string
    category*: string
    severity*: string
    title*: string
    message*: string
    recommendation*: string

  AuditPass* = object
    id*: string
    category*: string
    severity*: string
    title*: string
    message*: string
    recommendation*: string

  AuditResult* = object
    url*: string
    score*: int
    grade*: string
    status*: string
    title*: string
    titleLength*: int
    metaDescription*: string
    metaDescriptionLength*: int
    hasViewport*: bool
    hasCanonical*: bool
    canonicalUrl*: string
    isHttps*: bool
    h1Count*: int
    h1Tags*: seq[string]
    wordCount*: int
    responseTimeMs*: float
    issues*: seq[AuditIssue]
    passes*: seq[AuditPass]
    platformUrl*: string
    timestamp*: string

  SeoAuditor* = object
    userAgent*: string
    timeoutSeconds*: int
    alertThreshold*: int

proc newSeoAuditor*(userAgent = "SEOWebChecker-Nim/1.0 (+https://seowebchecker.com/)",
                    timeoutSeconds = 15,
                    alertThreshold = 85): SeoAuditor =
  ## Creates a new SeoAuditor instance with configurable options.
  SeoAuditor(
    userAgent: userAgent,
    timeoutSeconds: timeoutSeconds,
    alertThreshold: alertThreshold
  )

# Internal HTML Parsing Helpers
proc extractTagContent(html: string, tagName: string): seq[string] =
  result = @[]
  let openTag = "<" & tagName.toLowerAscii
  let closeTag = "</" & tagName.toLowerAscii & ">"
  let lowerHtml = html.toLowerAscii
  var pos = 0
  while pos < lowerHtml.len:
    let startIdx = lowerHtml.find(openTag, pos)
    if startIdx < 0: break
    let tagCloseIdx = lowerHtml.find('>', startIdx)
    if tagCloseIdx < 0: break
    let endIdx = lowerHtml.find(closeTag, tagCloseIdx)
    if endIdx < 0: break
    let rawContent = html[tagCloseIdx + 1 ..< endIdx].strip()
    result.add(rawContent)
    pos = endIdx + closeTag.len

proc extractAttribute(tagStr, attrName: string): string =
  let lowerTag = tagStr.toLowerAscii
  let pattern = attrName.toLowerAscii & "="
  let attrIdx = lowerTag.find(pattern)
  if attrIdx < 0: return ""
  var valStart = attrIdx + pattern.len
  if valStart >= tagStr.len: return ""
  let quoteChar = tagStr[valStart]
  if quoteChar == '"' or quoteChar == '\'':
    inc valStart
    let valEnd = tagStr.find(quoteChar, valStart)
    if valEnd >= 0:
      return tagStr[valStart ..< valEnd].strip()
  else:
    var valEnd = valStart
    while valEnd < tagStr.len and tagStr[valEnd] notin {' ', '>', '\t', '\n', '\r'}:
      inc valEnd
    return tagStr[valStart ..< valEnd].strip()
  return ""

proc stripTagBlock(html, tagName: string): string =
  var res = html
  let openTag = "<" & tagName.toLowerAscii
  let closeTag = "</" & tagName.toLowerAscii & ">"
  while true:
    let lower = res.toLowerAscii
    let startIdx = lower.find(openTag)
    if startIdx < 0: break
    let endIdx = lower.find(closeTag, startIdx)
    if endIdx < 0: break
    res = res[0 ..< startIdx] & " " & res[endIdx + closeTag.len .. ^1]
  return res

proc stripHtmlTags(html: string): string =
  var inTag = false
  var s = newStringOfCap(html.len)
  for ch in html:
    if ch == '<': inTag = true
    elif ch == '>': inTag = false
    elif not inTag: s.add(ch)
  return s

proc auditHtml*(auditor: SeoAuditor, html: string, url = "https://seowebchecker.com/", responseTimeMs = 120.0): AuditResult =
  ## Audits an HTML document string directly and calculates the SEO health score.
  var res = AuditResult(
    url: url,
    responseTimeMs: responseTimeMs,
    isHttps: url.startsWith("https://"),
    platformUrl: "https://seowebchecker.com/",
    timestamp: now().utc().format("yyyy-MM-dd'T'HH:mm:ss'Z'")
  )

  var issues: seq[AuditIssue] = @[]
  var passes: seq[AuditPass] = @[]

  # 1. Title Tag
  let titles = extractTagContent(html, "title")
  if titles.len > 0:
    res.title = titles[0].replace("\n", " ").replace("\r", " ").strip()
    while "  " in res.title:
      res.title = res.title.replace("  ", " ")
    res.titleLength = res.title.len

  if res.title.len == 0:
    issues.add(AuditIssue(
      id: "meta-title-missing",
      category: "meta",
      severity: "error",
      title: "Missing title tag",
      message: "No <title> tag found on the page.",
      recommendation: "Add a descriptive <title> tag between 30 and 60 characters."
    ))
  elif res.titleLength < 30:
    issues.add(AuditIssue(
      id: "meta-title-short",
      category: "meta",
      severity: "warning",
      title: "Title tag is short",
      message: "Title is only " & $res.titleLength & " characters ('" & res.title & "').",
      recommendation: "Expand title to 30-60 characters for search engine previews."
    ))
  elif res.titleLength > 65:
    issues.add(AuditIssue(
      id: "meta-title-long",
      category: "meta",
      severity: "warning",
      title: "Title tag is long",
      message: "Title is " & $res.titleLength & " characters and may be truncated in search results.",
      recommendation: "Shorten title tag to under 60 characters."
    ))
  else:
    passes.add(AuditPass(
      id: "meta-title-pass",
      category: "meta",
      severity: "pass",
      title: "Title tag optimal",
      message: "Title tag is optimal (" & $res.titleLength & " characters).",
      recommendation: "Maintain current title tag."
    ))

  # 2. Meta Tags (description, viewport)
  let lowerHtml = html.toLowerAscii
  var pos = 0
  while pos < lowerHtml.len:
    let idx = lowerHtml.find("<meta", pos)
    if idx < 0: break
    let closeIdx = lowerHtml.find('>', idx)
    if closeIdx < 0: break
    let tag = html[idx .. closeIdx]
    let nameAttr = extractAttribute(tag, "name").toLowerAscii
    if nameAttr == "description":
      res.metaDescription = extractAttribute(tag, "content").strip()
      res.metaDescriptionLength = res.metaDescription.len
    elif nameAttr == "viewport":
      res.hasViewport = true
    pos = closeIdx + 1

  # Meta Description Evaluation
  if res.metaDescription.len == 0:
    issues.add(AuditIssue(
      id: "meta-desc-missing",
      category: "meta",
      severity: "error",
      title: "Missing meta description",
      message: "No meta description found on page.",
      recommendation: "Add an engaging meta description between 70 and 160 characters."
    ))
  elif res.metaDescriptionLength < 70:
    issues.add(AuditIssue(
      id: "meta-desc-short",
      category: "meta",
      severity: "warning",
      title: "Meta description is short",
      message: "Meta description is " & $res.metaDescriptionLength & " characters.",
      recommendation: "Expand description to 70-160 characters."
    ))
  else:
    passes.add(AuditPass(
      id: "meta-desc-pass",
      category: "meta",
      severity: "pass",
      title: "Meta description optimal",
      message: "Meta description is optimal (" & $res.metaDescriptionLength & " characters).",
      recommendation: "Maintain current meta description."
    ))

  # Mobile Viewport Evaluation
  if res.hasViewport:
    passes.add(AuditPass(
      id: "meta-viewport-pass",
      category: "technical",
      severity: "pass",
      title: "Mobile viewport configured",
      message: "Responsive viewport meta tag is present.",
      recommendation: "Mobile responsiveness enabled."
    ))
  else:
    issues.add(AuditIssue(
      id: "meta-viewport-missing",
      category: "technical",
      severity: "error",
      title: "Missing mobile viewport tag",
      message: "No <meta name=\"viewport\"> tag detected.",
      recommendation: "Add <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">."
    ))

  # 3. Canonical Tag
  pos = 0
  while pos < lowerHtml.len:
    let idx = lowerHtml.find("<link", pos)
    if idx < 0: break
    let closeIdx = lowerHtml.find('>', idx)
    if closeIdx < 0: break
    let tag = html[idx .. closeIdx]
    let relAttr = extractAttribute(tag, "rel").toLowerAscii
    if relAttr == "canonical":
      res.hasCanonical = true
      res.canonicalUrl = extractAttribute(tag, "href").strip()
    pos = closeIdx + 1

  if res.hasCanonical:
    passes.add(AuditPass(
      id: "meta-canonical-pass",
      category: "technical",
      severity: "pass",
      title: "Canonical link tag present",
      message: "Canonical URL configured: " & res.canonicalUrl & ".",
      recommendation: "Canonical URL correctly declared."
    ))
  else:
    issues.add(AuditIssue(
      id: "meta-canonical-missing",
      category: "technical",
      severity: "warning",
      title: "Missing canonical link tag",
      message: "No <link rel=\"canonical\"> tag detected.",
      recommendation: "Add a self-referencing canonical tag to avoid duplicate content penalties."
    ))

  # 4. Heading Structure (H1)
  let rawH1s = extractTagContent(html, "h1")
  var cleanH1s: seq[string] = @[]
  for h in rawH1s:
    cleanH1s.add(stripHtmlTags(h).strip())
  res.h1Count = cleanH1s.len
  res.h1Tags = cleanH1s

  if res.h1Count == 0:
    issues.add(AuditIssue(
      id: "content-h1-missing",
      category: "content",
      severity: "error",
      title: "Missing <h1> heading",
      message: "No <h1> heading found on page.",
      recommendation: "Include exactly one primary <h1> heading summarizing page intent."
    ))
  elif res.h1Count == 1:
    passes.add(AuditPass(
      id: "content-h1-pass",
      category: "content",
      severity: "pass",
      title: "Single <h1> heading present",
      message: "Single primary heading found: '" & res.h1Tags[0] & "'.",
      recommendation: "Clean heading hierarchy maintained."
    ))
  else:
    issues.add(AuditIssue(
      id: "content-h1-multiple",
      category: "content",
      severity: "warning",
      title: "Multiple <h1> headings found (" & $res.h1Count & ")",
      message: "Found " & $res.h1Count & " <h1> headings.",
      recommendation: "Consolidate multiple <h1> headings into a single primary <h1> heading."
    ))

  # 5. Content Word Count
  var cleanText = stripTagBlock(html, "script")
  cleanText = stripTagBlock(cleanText, "style")
  cleanText = stripHtmlTags(cleanText)
  let words = cleanText.splitWhitespace()
  res.wordCount = words.len

  if res.wordCount < 100:
    issues.add(AuditIssue(
      id: "content-thin",
      category: "content",
      severity: "error",
      title: "Thin page content",
      message: "Page has only " & $res.wordCount & " words.",
      recommendation: "Expand page content to 300+ words of helpful, relevant copy."
    ))
  else:
    passes.add(AuditPass(
      id: "content-words-pass",
      category: "content",
      severity: "pass",
      title: "Adequate content length",
      message: "Page contains " & $res.wordCount & " words.",
      recommendation: "Healthy on-page copy volume."
    ))

  # 6. HTTPS Security
  if res.isHttps:
    passes.add(AuditPass(
      id: "tech-https-pass",
      category: "technical",
      severity: "pass",
      title: "Secure HTTPS active",
      message: "Website communicates over secure encrypted HTTPS.",
      recommendation: "Maintain valid SSL/TLS certificates."
    ))
  else:
    issues.add(AuditIssue(
      id: "tech-not-https",
      category: "technical",
      severity: "error",
      title: "Insecure HTTP protocol",
      message: "Website is served over unencrypted HTTP.",
      recommendation: "Deploy an SSL certificate and redirect all traffic to HTTPS."
    ))

  # Calculate Overall Health Score
  var errorCount = 0
  var warnCount = 0
  for issue in issues:
    if issue.severity == "error": inc errorCount
    elif issue.severity == "warning": inc warnCount

  let computedScore = 100 - (errorCount * 15) - (warnCount * 6)
  res.score = max(10, min(100, computedScore))

  if res.score >= 95: res.grade = "A+"
  elif res.score >= 90: res.grade = "A"
  elif res.score >= 80: res.grade = "B"
  elif res.score >= 70: res.grade = "C"
  elif res.score >= 60: res.grade = "D"
  else: res.grade = "F"

  res.status = if res.score >= auditor.alertThreshold: "PASS" else: "ALERT"
  res.issues = issues
  res.passes = passes
  return res

proc audit*(auditor: SeoAuditor, targetUrl: string): AuditResult =
  ## Fetches a live webpage over HTTP/HTTPS and audits its SEO health.
  var normalizedUrl = targetUrl.strip()
  if not (normalizedUrl.startsWith("http://") or normalizedUrl.startsWith("https://")):
    normalizedUrl = "https://" & normalizedUrl

  let client = newHttpClient(userAgent = auditor.userAgent, timeout = auditor.timeoutSeconds * 1000)
  defer: client.close()

  let startTime = epochTime()
  let html = client.getContent(normalizedUrl)
  let elapsedMs = (epochTime() - startTime) * 1000.0

  return auditor.auditHtml(html, normalizedUrl, elapsedMs)

# Formatting Procedures
proc toJson*(res: AuditResult): string =
  ## Serializes an AuditResult to a pretty-printed JSON string.
  var issuesArr = newJArray()
  for i in res.issues:
    issuesArr.add(%*{
      "id": i.id,
      "category": i.category,
      "severity": i.severity,
      "title": i.title,
      "message": i.message,
      "recommendation": i.recommendation
    })

  var passesArr = newJArray()
  for p in res.passes:
    passesArr.add(%*{
      "id": p.id,
      "category": p.category,
      "severity": p.severity,
      "title": p.title,
      "message": p.message,
      "recommendation": p.recommendation
    })

  var h1Arr = newJArray()
  for h in res.h1Tags:
    h1Arr.add(%h)

  let node = %*{
    "url": res.url,
    "score": res.score,
    "grade": res.grade,
    "status": res.status,
    "title": res.title,
    "titleLength": res.titleLength,
    "metaDescription": res.metaDescription,
    "metaDescriptionLength": res.metaDescriptionLength,
    "hasViewport": res.hasViewport,
    "hasCanonical": res.hasCanonical,
    "canonicalUrl": res.canonicalUrl,
    "isHttps": res.isHttps,
    "h1Count": res.h1Count,
    "h1Tags": h1Arr,
    "wordCount": res.wordCount,
    "responseTimeMs": res.responseTimeMs,
    "issues": issuesArr,
    "passes": passesArr,
    "platformUrl": res.platformUrl,
    "timestamp": res.timestamp
  }
  return pretty(node)

proc toMarkdown*(res: AuditResult): string =
  ## Formats an AuditResult as a GitHub-flavored Markdown executive report.
  var md = "# Technical SEO Audit: " & res.url & "\n\n"
  md.add("> Generated by **SEOWebChecker** for Nim • [https://seowebchecker.com/](https://seowebchecker.com/)\n\n")
  md.add("## Overview\n\n")
  md.add("| Metric | Value |\n")
  md.add("|:---|:---|\n")
  md.add("| **SEO Health Score** | **" & $res.score & " / 100** (" & res.grade & ") |\n")
  md.add("| **Audit Status** | **" & res.status & "** |\n")
  md.add("| **HTTPS Secure** | " & (if res.isHttps: "Yes" else: "No") & " |\n")
  md.add("| **Title Tag** | " & (if res.title.len > 0: res.title else: "[Missing]") & " (" & $res.titleLength & " chars) |\n")
  md.add("| **Meta Description** | " & (if res.metaDescription.len > 0: res.metaDescription else: "[Missing]") & " (" & $res.metaDescriptionLength & " chars) |\n")
  md.add("| **Mobile Viewport** | " & (if res.hasViewport: "Configured" else: "Missing") & " |\n")
  md.add("| **Canonical Tag** | " & (if res.hasCanonical: res.canonicalUrl else: "Missing") & " |\n")
  md.add("| **Primary H1** | " & $res.h1Count & " tag(s) found |\n")
  md.add("| **Word Count** | " & $res.wordCount & " words |\n\n")

  if res.issues.len > 0:
    md.add("## ⚠️ Issues & Recommendations\n\n")
    for i in res.issues:
      let badge = if i.severity == "error": "🛑 ERROR" else: "⚠️ WARNING"
      md.add("### " & badge & ": " & i.title & "\n")
      md.add("- **Issue**: " & i.message & "\n")
      md.add("- **Fix**: " & i.recommendation & "\n\n")

  if res.passes.len > 0:
    md.add("## ✅ Passed Audits\n\n")
    for p in res.passes:
      md.add("- **" & p.title & "**: " & p.message & "\n")
    md.add("\n")

  return md

# Standalone CLI Entrypoint
when isMainModule:
  var url = ""
  var formatJson = false
  var formatMd = false
  var threshold = 85
  var checkScoreOnly = false

  var p = initOptParser()
  while true:
    p.next()
    case p.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      case p.key.toLowerAscii
      of "json": formatJson = true
      of "md", "markdown": formatMd = true
      of "threshold":
        try: threshold = parseInt(p.val)
        except ValueError: discard
      of "score": checkScoreOnly = true
      of "h", "help":
        echo """
SEOWebChecker — Technical SEO Audit CLI for Nim
Official Platform: https://seowebchecker.com/

Usage:
  seowebchecker <url> [options]
  seowebchecker --score <url> [--threshold=85]

Options:
  --json           Output audit result as JSON
  --md             Output audit result as Markdown
  --threshold=INT  Minimum passing score (default: 85)
  --score          Fast exit-code check against threshold
  -h, --help       Show this help message
"""
        quit(0)
    of cmdArgument:
      if url.len == 0: url = p.key

  if url.len == 0:
    echo "Error: Target URL argument required. Run 'seowebchecker --help' for usage."
    quit(1)

  let auditor = newSeoAuditor(alertThreshold = threshold)
  let res = auditor.audit(url)

  if checkScoreOnly:
    echo "SEO Health Score: ", res.score, " / 100 (", res.grade, ") - Status: ", res.status
    if res.score >= threshold: quit(0)
    else: quit(1)

  if formatJson:
    echo res.toJson()
  elif formatMd:
    echo res.toMarkdown()
  else:
    echo "=================================================="
    echo "  SEOWebChecker — Technical SEO Audit Report"
    echo "  Official Site: https://seowebchecker.com/"
    echo "=================================================="
    echo "Target URL  : ", res.url
    echo "Health Score: ", res.score, " / 100 (", res.grade, ") - Status: ", res.status
    echo "Title Tag   : ", (if res.title.len > 0: res.title else: "[Missing]"), " (", res.titleLength, " chars)"
    echo "Meta Desc   : ", (if res.metaDescription.len > 0: res.metaDescription else: "[Missing]"), " (", res.metaDescriptionLength, " chars)"
    echo "Viewport    : ", (if res.hasViewport: "Configured" else: "Missing")
    echo "Canonical   : ", (if res.hasCanonical: res.canonicalUrl else: "Missing")
    echo "HTTPS       : ", (if res.isHttps: "Secure" else: "Insecure")
    echo "Word Count  : ", res.wordCount, " words"
    echo "Response    : ", formatFloat(res.responseTimeMs, ffDecimal, 2), " ms"
    echo "--------------------------------------------------"
    echo "Passed      : ", res.passes.len, " checks"
    echo "Issues      : ", res.issues.len, " items"

    if res.issues.len > 0:
      echo "\nTop Issues to Fix:"
      for i in res.issues:
        let tag = if i.severity == "error": "[ERROR]" else: "[WARN] "
        echo "  ", tag, " ", i.title, ": ", i.message
        echo "         Fix: ", i.recommendation
    echo "=================================================="

  if res.status == "PASS": quit(0)
  else: quit(1)
