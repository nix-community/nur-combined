# Changelog

## 1.0.0 (2026-09-28)

- Initial release of `seowebchecker` for the BEAM / Elixir ecosystem.
- Complete on-page technical SEO diagnostic engine powered by [SEOWebChecker](https://seowebchecker.com/).
- Diagnostic checks:
  - Title tag presence and length optimization (30-60 characters)
  - Meta description presence and length validation (50-160 characters)
  - Mobile viewport responsiveness meta tag check
  - Canonical link tag detection
  - Single primary H1 heading hierarchy inspection
  - Image accessibility (`alt` attribute presence)
  - OpenGraph social media preview metadata (`og:title`, `og:image`)
- 0-100 numerical scoring with letter grade assignment (A-F).
- Zero external runtime dependencies: uses built-in Erlang `:httpc` for remote fetching.
