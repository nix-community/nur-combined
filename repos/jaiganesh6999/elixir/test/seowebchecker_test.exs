defmodule SeoWebCheckerTest do
  use ExUnit.Case
  doctest SeoWebChecker

  @perfect_html """
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <title>Optimal Page Title Tag for High Search Ranking</title>
      <meta name="description" content="A comprehensive guide to modern on-page technical SEO, heading structure, and Core Web Vitals optimization.">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <link rel="canonical" href="https://example.com/perfect">
      <meta property="og:title" content="Optimal Page Title Tag">
      <meta property="og:image" content="https://example.com/og.jpg">
  </head>
  <body>
      <h1>Mastering Technical SEO for 2026</h1>
      <p>Welcome to our checklist.</p>
      <img src="chart.png" alt="SEO Performance Growth">
  </body>
  </html>
  """

  @bad_html """
  <!DOCTYPE html>
  <html>
  <head></head>
  <body>
      <div>Missing title, description, viewport, canonical, and h1.</div>
      <img src="pic.jpg">
  </body>
  </html>
  """

  test "perfect HTML returns 100/100 and Grade A" do
    result = SeoWebChecker.audit_html(@perfect_html, url: "https://example.com/perfect")

    assert result.score.overall == 100
    assert result.score.grade == "A"
    assert result.errors == 0
    assert result.warnings == 0
    assert result.metadata["title"] == "Optimal Page Title Tag for High Search Ranking"
    assert result.metadata["h1"] == "Mastering Technical SEO for 2026"
  end

  test "defective HTML reports errors and low score" do
    result = SeoWebChecker.audit_html(@bad_html, url: "https://example.com/bad")

    assert result.score.overall < 60
    assert result.errors >= 3

    issue_ids = Enum.map(result.issues, & &1.id)
    assert "meta-title-missing" in issue_ids
    assert "meta-desc-missing" in issue_ids
    assert "h1-missing" in issue_ids
    assert "img-alt-missing" in issue_ids
  end

  test "short and long length checks generate warnings" do
    short_html = """
    <!DOCTYPE html><html><head>
    <title>Short</title>
    <meta name="description" content="Too short">
    <meta name="viewport" content="width=device-width">
    </head><body><h1>Heading</h1></body></html>
    """

    res_short = SeoWebChecker.audit_html(short_html)
    short_ids = Enum.map(res_short.issues, & &1.id)
    assert "meta-title-short" in short_ids
    assert "meta-desc-short" in short_ids
  end

  test "multiple H1 tags generates warning" do
    multi_h1_html = """
    <!DOCTYPE html><html><head>
    <title>Valid Title With Proper Character Count Here</title>
    <meta name="description" content="Valid description length with sufficient keywords and call to action text.">
    <meta name="viewport" content="width=device-width">
    </head><body>
    <h1>First H1</h1>
    <h1>Second H1</h1>
    </body></html>
    """

    res = SeoWebChecker.audit_html(multi_h1_html)
    ids = Enum.map(res.issues, & &1.id)
    assert "h1-multiple" in ids
  end
end
