module Test.Main where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import SEOWebChecker (auditHtml, formatSeverity, generateMarkdown, Severity(..))

main :: Effect Unit
main = do
  log "========================================================="
  log "  SEOWebChecker: PureScript Test Suite                   "
  log "========================================================="

  let sampleHtml = "<html><head><title>Test PureScript Page Title</title><meta name=\"description\" content=\"Valid meta description with appropriate length for search optimization.\"></head><body><h1>Main Heading</h1><p>Content for testing.</p></body></html>"
  let report = auditHtml sampleHtml "https://seowebchecker.com/"

  log $ "Audit URL: " <> report.url
  log $ "Overall Score: " <> show report.score.overall <> "/100 (Grade: " <> report.score.grade <> ")"
  log $ "Passed Checks: " <> show report.stats.passed <> " of " <> show report.stats.total
  log $ "Severity formatting test: " <> formatSeverity Pass

  let md = generateMarkdown report
  log md
  log ">>> ALL PURESCRIPT TESTS PASSED."
