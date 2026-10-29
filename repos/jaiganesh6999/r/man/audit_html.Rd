\name{audit_html}
\alias{audit_html}
\title{Audit HTML Content for On-Page SEO}
\usage{
audit_html(html, url = "https://example.com")
}
\arguments{
\item{html}{A character string or character vector containing the raw HTML to audit.}

\item{url}{An optional character string representing the URL being audited. Defaults to \code{"https://example.com"}.}
}
\value{
An object of class \code{"seo_audit_result"} containing:
\item{url}{Target URL evaluated.}
\item{score}{List with \code{overall} (0-100) and \code{grade} (A-F).}
\item{total_checks}{Total number of diagnostic checks performed.}
\item{passed_checks}{Count of passed checks.}
\item{warnings}{Count of warning-level issues.}
\item{errors}{Count of error-level issues.}
\item{issues}{A list of individual issue descriptions and recommendations.}
\item{metadata}{Extracted page metadata (title, description, canonical, h1).}
}
\description{
Evaluates an HTML string against on-page SEO best practices including title, meta description, mobile viewport, canonical link, heading tags, image alt attributes, and OpenGraph social tags.
}
\examples{
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
}
