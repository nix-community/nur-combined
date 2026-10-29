\name{audit_url}
\alias{audit_url}
\title{Audit Live Website URL for SEO}
\usage{
audit_url(url, user_agent = "SEOWebChecker-RBot/1.0 (+https://seowebchecker.com/)")
}
\arguments{
\item{url}{A character string representing the URL to fetch and audit.}

\item{user_agent}{A character string specifying the HTTP User-Agent header. Defaults to \code{"SEOWebChecker-RBot/1.0 (+https://seowebchecker.com/)"}.}
}
\value{
An object of class \code{"seo_audit_result"}.
}
\description{
Fetches raw HTML from a target URL and performs automated on-page technical SEO analysis.
}
\examples{
\dontrun{
res <- audit_url("https://seowebchecker.com/")
print(res)
}
}
