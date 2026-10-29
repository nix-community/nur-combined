test_that("audit_html correctly parses valid HTML", {
  sample_html <- paste0(
    "<!DOCTYPE html><html lang='en'><head>",
    "<title>SEOWebChecker: Free SEO Audit & Analysis Tools</title>",
    "<meta name='description' content='Audit your website with SEOWebChecker for comprehensive SEO scoring.'>",
    "<meta name='viewport' content='width=device-width, initial-scale=1.0'>",
    "<link rel='canonical' href='https://seowebchecker.com/'>",
    "<meta property='og:title' content='SEOWebChecker SEO Audit'>",
    "<meta property='og:image' content='https://seowebchecker.com/logo.png'>",
    "</head><body>",
    "<h1>Comprehensive SEO Audit Tools</h1>",
    "<img src='banner.jpg' alt='Dashboard preview'>",
    "</body></html>"
  )

  res <- audit_html(sample_html, url = "https://seowebchecker.com/")

  expect_s3_class(res, "seo_audit_result")
  expect_equal(res$url, "https://seowebchecker.com/")
  expect_gte(res$score$overall, 90)
  expect_equal(res$score$grade, "A")
  expect_equal(res$errors, 0)
  expect_gte(res$passed_checks, 5)
  expect_equal(res$metadata$title, "SEOWebChecker: Free SEO Audit & Analysis Tools")
  expect_equal(res$metadata$h1, "Comprehensive SEO Audit Tools")
})

test_that("audit_html detects missing tags", {
  empty_html <- "<html><body><p>Hello world</p></body></html>"
  res <- audit_html(empty_html)

  expect_gt(res$errors, 0)
  expect_lt(res$score$overall, 80)
})
