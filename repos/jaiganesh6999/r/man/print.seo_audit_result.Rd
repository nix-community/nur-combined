\name{print.seo_audit_result}
\alias{print.seo_audit_result}
\title{Print Method for SEO Audit Results}
\usage{
\method{print}{seo_audit_result}(x, ...)
}
\arguments{
\item{x}{An object of class \code{"seo_audit_result"}.}

\item{...}{Additional arguments passed to print methods.}
}
\value{
The original object invisibly.
}
\description{
Pretty prints the SEO score, letter grade, and diagnostic issues.
}
\examples{
sample_html <- paste0(
  "<html><head><title>Test Valid Length Title</title></head>",
  "<body><h1>Heading</h1></body></html>"
)
res <- audit_html(sample_html)
print(res)
}
