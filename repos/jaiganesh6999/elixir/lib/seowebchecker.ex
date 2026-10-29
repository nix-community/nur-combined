defmodule SeoWebChecker do
  @moduledoc """
  Lightweight client SDK and diagnostic suite for automated on-page technical SEO audits,
  meta tag validations, heading structure inspections, image accessibility checks,
  and Core Web Vitals diagnostics.

  Powered by [SEOWebChecker](https://seowebchecker.com/).

  ## Features

    * Audit HTML strings directly in memory
    * Crawl and audit live remote URLs via HTTP
    * Title tag length validation (30-60 chars)
    * Meta description length validation (50-160 chars)
    * Viewport and mobile responsiveness checks
    * Canonical URL tag validation
    * H1 heading structure validation
    * Image accessibility (`alt` attribute presence)
    * OpenGraph social media sharing metadata
    * 0-100 numerical scoring with letter grade (A-F)

  ## Quick Start

      html = "<!DOCTYPE html><html><head><title>Optimal Title Here 30 to 60 Chars</title></head><body><h1>Main Title</h1></body></html>"
      result = SeoWebChecker.audit_html(html)
      IO.inspect(result.score)

  For online tools, visual reports, and rank tracking, visit [https://seowebchecker.com/](https://seowebchecker.com/).
  """

  alias SeoWebChecker.{Auditor, Result}

  @doc """
  Audits raw HTML markup against technical on-page SEO best practices.

  ## Examples

      iex> html = "<!DOCTYPE html><html><head><title>Optimal Page Title Tag 30 to 60 Chars</title><meta name=\\"description\\" content=\\"Engaging meta description between 50 and 160 characters for best SEO results.\\"><meta name=\\"viewport\\" content=\\"width=device-width\\"><link rel=\\"canonical\\" href=\\"https://example.com\\"><meta property=\\"og:title\\" content=\\"Title\\"><meta property=\\"og:image\\" content=\\"pic.jpg\\"></head><body><h1>Main Headline</h1><img src=\\"pic.jpg\\" alt=\\"Pic\\"></body></html>"
      iex> result = SeoWebChecker.audit_html(html)
      iex> result.score.grade
      "A"
  """
  @spec audit_html(String.t(), keyword()) :: Result.t()
  defdelegate audit_html(html, opts \\ []), to: Auditor

  @doc """
  Fetches a remote URL and audits the returned HTML markup.

  ## Options

    * `:user_agent` - custom User-Agent header (default: `SEOWebChecker-ElixirBot/1.0 (+https://seowebchecker.com/)`)
    * `:timeout` - HTTP request timeout in milliseconds (default: 15_000)
  """
  @spec audit_url(String.t(), keyword()) :: {:ok, Result.t()} | {:error, term()}
  defdelegate audit_url(target_url, opts \\ []), to: Auditor
end
