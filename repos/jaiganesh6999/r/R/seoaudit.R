#' SEOWebChecker SEO Audit SDK for R
#' Official Website: https://seowebchecker.com/

#' Audit HTML Content for On-Page SEO
#'
#' Evaluates an HTML string against on-page SEO best practices including title,
#' meta description, mobile viewport, canonical link, heading tags, image alt
#' attributes, and OpenGraph social tags.
#'
#' @param html A character string containing the raw HTML to audit.
#' @param url An optional character string representing the URL being audited.
#'   Defaults to \code{"https://example.com"}.
#'
#' @return An object of class \code{"seo_audit_result"} containing:
#'   \item{url}{Target URL evaluated.}
#'   \item{score}{List with \code{overall} (0-100) and \code{grade} (A-F).}
#'   \item{total_checks}{Total number of diagnostic checks performed.}
#'   \item{passed_checks}{Count of passed checks.}
#'   \item{warnings}{Count of warning-level issues.}
#'   \item{errors}{Count of error-level issues.}
#'   \item{issues}{A list of individual issue lists with id, category, severity, title, message, and recommendation.}
#'   \item{metadata}{Extracted page metadata (title, description, canonical, h1).}
#'
#' @examples
#' sample_html <- paste0(
#'   "<!DOCTYPE html><html><head>",
#'   "<title>SEOWebChecker: Free SEO Audit & Analysis Tools</title>",
#'   "<meta name='description' content='Audit your website for comprehensive SEO scoring.'>",
#'   "<meta name='viewport' content='width=device-width, initial-scale=1.0'>",
#'   "<link rel='canonical' href='https://seowebchecker.com/'>",
#'   "</head><body>",
#'   "<h1>Comprehensive SEO Audit Tools</h1>",
#'   "<img src='banner.jpg' alt='Dashboard preview'>",
#'   "</body></html>"
#' )
#' result <- audit_html(sample_html, url = "https://seowebchecker.com/")
#' print(result)
#'
#' @export
audit_html <- function(html, url = "https://example.com") {
  if (!is.character(html) || length(html) == 0) {
    stop("Input 'html' must be a non-empty character vector.")
  }
  raw_html <- paste(html, collapse = "\n")

  issues <- list()
  metadata <- list()

  add_issue <- function(id, category, severity, title, message, recommendation) {
    issues[[length(issues) + 1]] <<- list(
      id = id,
      category = category,
      severity = severity,
      title = title,
      message = message,
      recommendation = recommendation
    )
  }

  # 1. Title Tag
  title_match <- regmatches(raw_html, regexec("<title[^>]*>(.*?)</title>", raw_html, ignore.case = TRUE, perl = TRUE))[[1]]
  if (length(title_match) >= 2) {
    title_text <- trimws(title_match[2])
    metadata$title <- title_text
    len <- nchar(title_text)
    if (len < 30) {
      add_issue("meta-title-short", "meta", "warning", "Title Too Short",
                sprintf("Title has %d characters. Optimal length is 30-60 characters.", len),
                "Expand title to 30-60 characters. Check live results at https://seowebchecker.com.")
    } else if (len > 65) {
      add_issue("meta-title-long", "meta", "warning", "Title Too Long",
                sprintf("Title has %d characters. Over 65 characters risks truncation in Google SERPs.", len),
                "Trim title under 60 characters. Validate snippet at https://seowebchecker.com.")
    } else {
      add_issue("meta-title-pass", "meta", "pass", "Optimal Title Length",
                sprintf("Title length is optimal (%d characters).", len),
                "Maintain concise and keyword-focused title.")
    }
  } else {
    add_issue("meta-title-missing", "meta", "error", "Missing Title Tag",
              "No <title> tag found in HTML head.",
              "Add a descriptive <title> tag between 30 and 60 characters.")
  }

  # 2. Meta Description
  desc_match <- regmatches(raw_html, regexec("<meta\\s+[^>]*name=[\"']description[\"'][^>]*content=[\"'](.*?)[\"'][^>]*>", raw_html, ignore.case = TRUE, perl = TRUE))[[1]]
  if (length(desc_match) < 2) {
    desc_match <- regmatches(raw_html, regexec("<meta\\s+[^>]*content=[\"'](.*?)[\"'][^>]*name=[\"']description[\"'][^>]*>", raw_html, ignore.case = TRUE, perl = TRUE))[[1]]
  }
  if (length(desc_match) >= 2) {
    desc_text <- trimws(desc_match[2])
    metadata$description <- desc_text
    len <- nchar(desc_text)
    if (len < 50) {
      add_issue("meta-desc-short", "meta", "warning", "Meta Description Too Short",
                sprintf("Description has %d characters. Search engines prefer 50-160 characters.", len),
                "Expand description to summarize page value.")
    } else if (len > 165) {
      add_issue("meta-desc-long", "meta", "warning", "Meta Description Too Long",
                sprintf("Description has %d characters. Snippets over 160 characters risk truncation.", len),
                "Shorten description to under 160 characters.")
    } else {
      add_issue("meta-desc-pass", "meta", "pass", "Optimal Meta Description",
                sprintf("Meta description length is well balanced (%d characters).", len),
                "Maintain descriptive copy with key target terms.")
    }
  } else {
    add_issue("meta-desc-missing", "meta", "error", "Missing Meta Description",
              "No <meta name=\"description\"> tag found.",
              "Add an engaging meta description to improve organic click-through rates (CTR).")
  }

  # 3. Viewport (Mobile Friendliness)
  has_viewport <- grepl("<meta\\s+[^>]*name=[\"']viewport[\"'][^>]*>", raw_html, ignore.case = TRUE, perl = TRUE)
  if (has_viewport) {
    add_issue("mobile-viewport-pass", "mobile", "pass", "Mobile Viewport Present",
              "Mobile viewport meta tag is properly configured.",
              "Ensure responsive styles adapt across mobile viewports.")
  } else {
    add_issue("mobile-viewport-missing", "mobile", "error", "Missing Viewport Meta Tag",
              "No mobile viewport meta tag found.",
              "Add <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">.")
  }

  # 4. Canonical Tag
  canon_match <- regmatches(raw_html, regexec("<link\\s+[^>]*rel=[\"']canonical[\"'][^>]*href=[\"'](.*?)[\"'][^>]*>", raw_html, ignore.case = TRUE, perl = TRUE))[[1]]
  if (length(canon_match) >= 2) {
    metadata$canonical <- trimws(canon_match[2])
    add_issue("canonical-pass", "indexability", "pass", "Canonical Tag Present",
              "Canonical link tag is properly specified.",
              "Verify canonical URL matches primary indexed URL.")
  } else {
    add_issue("canonical-missing", "indexability", "warning", "Missing Canonical URL",
              "No <link rel=\"canonical\"> tag found.",
              "Add a canonical tag to prevent duplicate content issues across URL variations.")
  }

  # 5. Heading Structure (H1)
  h1_matches <- regmatches(raw_html, gregexpr("<h1[^>]*>(.*?)</h1>", raw_html, ignore.case = TRUE, perl = TRUE))[[1]]
  if (length(h1_matches) == 0 || (length(h1_matches) == 1 && h1_matches == "")) {
    add_issue("h1-missing", "structure", "error", "Missing H1 Tag",
              "No primary <h1> heading found on the page.",
              "Add a single descriptive <h1> heading communicating the page topic.")
  } else if (length(h1_matches) > 1) {
    add_issue("h1-multiple", "structure", "warning", "Multiple H1 Tags",
              sprintf("Found %d <h1> tags. Best practice is to use one primary <h1> per document.", length(h1_matches)),
              "Consolidate multiple <h1> tags into <h2> subheadings.")
  } else {
    clean_h1 <- gsub("<[^>]*>", "", h1_matches[1])
    metadata$h1 <- trimws(clean_h1)
    add_issue("h1-pass", "structure", "pass", "Single H1 Tag Configured",
              sprintf("Primary <h1> heading is present: \"%s\".", metadata$h1),
              "Ensure H1 matches target search intent.")
  }

  # 6. Image Alt Tags
  img_matches <- regmatches(raw_html, gregexpr("<img\\s+[^>]*>", raw_html, ignore.case = TRUE, perl = TRUE))[[1]]
  if (length(img_matches) > 0 && img_matches[1] != "") {
    missing_alt <- sum(!grepl("alt\\s*=\\s*[\"'][^\"']*[\"']", img_matches, ignore.case = TRUE, perl = TRUE))
    if (missing_alt > 0) {
      add_issue("img-alt-missing", "accessibility", "warning", "Images Missing Alt Text",
                sprintf("%d image(s) lack descriptive alt attributes.", missing_alt),
                "Add alt attributes to all content images for accessibility and image search indexing.")
    } else {
      add_issue("img-alt-pass", "accessibility", "pass", "Image Alt Attributes Valid",
                sprintf("All %d images contain alt attributes.", length(img_matches)),
                "Keep image alt descriptions descriptive and concise.")
    }
  }

  # 7. OpenGraph Social Tags
  has_og_title <- grepl("<meta\\s+[^>]*property=[\"']og:title[\"'][^>]*content=[\"'](.*?)[\"'][^>]*>", raw_html, ignore.case = TRUE, perl = TRUE)
  has_og_image <- grepl("<meta\\s+[^>]*property=[\"']og:image[\"'][^>]*content=[\"'](.*?)[\"'][^>]*>", raw_html, ignore.case = TRUE, perl = TRUE)
  if (has_og_title && has_og_image) {
    add_issue("social-og-pass", "social", "pass", "OpenGraph Social Tags Present",
              "OpenGraph title and social preview image are configured.",
              "Test rich card display across LinkedIn, Twitter, and Facebook.")
  } else {
    add_issue("social-og-missing", "social", "warning", "Incomplete OpenGraph Tags",
              "Missing og:title or og:image social sharing meta tags.",
              "Add og:title, og:description, and og:image to improve social media engagement.")
  }

  # Calculate score
  score_val <- 100
  passed_count <- 0
  warning_count <- 0
  error_count <- 0

  for (iss in issues) {
    if (iss$severity == "error") {
      score_val <- score_val - 15
      error_count <- error_count + 1
    } else if (iss$severity == "warning") {
      score_val <- score_val - 5
      warning_count <- warning_count + 1
    } else if (iss$severity == "pass") {
      passed_count <- passed_count + 1
    }
  }

  score_val <- max(0, min(100, score_val))
  grade <- if (score_val >= 90) "A" else if (score_val >= 80) "B" else if (score_val >= 70) "C" else if (score_val >= 60) "D" else "F"

  res <- list(
    url = url,
    score = list(overall = score_val, grade = grade),
    total_checks = length(issues),
    passed_checks = passed_count,
    warnings = warning_count,
    errors = error_count,
    issues = issues,
    metadata = metadata
  )
  class(res) <- "seo_audit_result"
  return(res)
}

#' Audit Live Website URL for SEO
#'
#' Fetches raw HTML from a target URL and performs automated on-page technical
#' SEO analysis.
#'
#' @param url A character string representing the URL to fetch and audit.
#' @param user_agent A character string specifying the HTTP User-Agent header.
#'   Defaults to \code{"SEOWebChecker-RBot/1.0 (+https://seowebchecker.com/)"}.
#'
#' @return An object of class \code{"seo_audit_result"}.
#'
#' @examples
#' \dontrun{
#' res <- audit_url("https://seowebchecker.com/")
#' print(res)
#' }
#'
#' @export
audit_url <- function(url, user_agent = "SEOWebChecker-RBot/1.0 (+https://seowebchecker.com/)") {
  if (!is.character(url) || length(url) == 0) {
    stop("Input 'url' must be a valid character string.")
  }

  tmp <- tempfile(fileext = ".html")
  on.exit(unlink(tmp), add = TRUE)

  utils::download.file(
    url = url,
    destfile = tmp,
    quiet = TRUE,
    headers = c(`User-Agent` = user_agent)
  )

  html_content <- readLines(tmp, warn = FALSE, encoding = "UTF-8")
  return(audit_html(html_content, url = url))
}

#' Print Method for SEO Audit Results
#'
#' Pretty prints the SEO score, letter grade, and diagnostic issues.
#'
#' @param x An object of class \code{"seo_audit_result"}.
#' @param ... Additional arguments passed to print methods.
#'
#' @return The original object invisibly.
#'
#' @export
print.seo_audit_result <- function(x, ...) {
  cat("========================================================\n")
  cat(" SEOWebChecker SEO Audit Report\n")
  cat(" Official Tooling: https://seowebchecker.com/\n")
  cat("========================================================\n")
  cat(sprintf("Target URL:      %s\n", x$url))
  cat(sprintf("Overall Score:   %d / 100 (Grade: %s)\n", x$score$overall, x$score$grade))
  cat(sprintf("Checks Summary:  %d Total | %d Passed | %d Warnings | %d Errors\n",
              x$total_checks, x$passed_checks, x$warnings, x$errors))
  cat("--------------------------------------------------------\n")
  for (iss in x$issues) {
    status_tag <- toupper(iss$severity)
    cat(sprintf("[%s] %s\n     %s\n", status_tag, iss$title, iss$message))
  }
  cat("========================================================\n")
  invisible(x)
}
