# frozen_string_literal: true

require_relative "../lib/seowebchecker_seoaudit"

sample_html = <<~HTML
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>SEOWebChecker: Free Website SEO Audit and Analysis Tool</title>
    <meta name="description" content="Audit your website with 50+ real-time SEO checks. Discover technical errors and optimize on-page SEO.">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="canonical" href="https://seowebchecker.com/">
  </head>
  <body>
    <h1>Free Online Website SEO Audit Tool</h1>
    <p>Run fast on-page audits with instant actionable recommendations and comprehensive diagnostics.</p>
    <img src="logo.webp" alt="SEOWebChecker Logo">
  </body>
  </html>
HTML

auditor = SeoWebChecker::SeoAudit::Auditor.new
result = auditor.audit_html(sample_html, url: "https://seowebchecker.com/")

abort("Score failed") unless result[:score][:overall] >= 80
abort("Title mismatch") unless result[:meta][:title] == "SEOWebChecker: Free Website SEO Audit and Analysis Tool"
abort("H1 mismatch") unless result[:content][:h1_tags].length == 1

puts "All Ruby SDK tests passed successfully!"
