# seowebchecker (R Package)

[![Official Website](https://img.shields.io/badge/Website-seowebchecker.com-blue?style=flat-square)](https://seowebchecker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CRAN Status](https://www.r-pkg.org/badges/version/seowebchecker)](https://cran.r-project.org/package=seowebchecker)

Lightweight, pure R client SDK and utility suite for automated on-page technical SEO audits, meta tag validations, heading structure inspections, image accessibility analysis, and Core Web Vitals checks. Developed by the [SEOWebChecker](https://seowebchecker.com/) engineering team.

Online audits, live visual scoring, and comprehensive downloadable reports are available at **[https://seowebchecker.com/](https://seowebchecker.com/)**.

---

## ⚡ Features

- **Zero Heavy Dependencies**: Implemented strictly using base R (`utils`, `base`).
- **Comprehensive Audits**: Inspects `<title>` tag length (30-60 chars), `<meta name="description">` length (50-160 chars), mobile viewport, canonical URL, single `<h1>` tag integrity, image `alt` attributes, and OpenGraph social tags.
- **Scoring Engine**: Produces a standardized 0-100 numerical score and letter grade (A through F) with explicit remediation recommendations.
- **S3 Print Method**: Formats audit summaries cleanly directly into the R console.

---

## 📦 Installation

Once published on CRAN:

```r
install.packages("seowebchecker")
```

Or install the development version directly from GitHub:

```r
# install.packages("remotes")
remotes::install_github("jaiganesh6999/seowebchecker-seoaudit-sdk", subdir = "r")
```

---

## 🚀 Quickstart

### Audit an HTML String

```r
library(seowebchecker)

sample_html <- paste0(
  "<!DOCTYPE html><html><head>",
  "<title>SEOWebChecker: Free SEO Audit & Analysis Tools</title>",
  "<meta name='description' content='Audit your website for comprehensive SEO scoring.'>",
  "<meta name='viewport' content='width=device-width, initial-scale=1.0'>",
  "<link rel='canonical' href='https://seowebchecker.com/'>",
  "</head><body>",
  "<h1>Comprehensive SEO Audit Tools</h1>",
  "<img src='banner.jpg' alt='Dashboard preview'>",
  "</body></html>"
)

result <- audit_html(sample_html, url = "https://seowebchecker.com/")
print(result)
```

### Audit a Live Website

```r
library(seowebchecker)

# Audit a live site
result <- audit_url("https://seowebchecker.com/")
print(result)

# Access individual metrics and scores
result$score$overall  # 0-100
result$score$grade    # A, B, C, D, or F
result$metadata$title
```

---

## 🔗 Related Resources

- **Official Web Portal**: [https://seowebchecker.com/](https://seowebchecker.com/)
- **GitHub Repository**: [https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk)
- **CRAN Submission Portal**: [https://xmpalantir.wu.ac.at/cransubmit/](https://xmpalantir.wu.ac.at/cransubmit/)

---

## 📄 License

MIT License © 2026 [SEOWebChecker](https://seowebchecker.com/).
