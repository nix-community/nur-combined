using Test
using SeoWebCheckerAudit

@testset "SeoWebCheckerAudit Tests" begin
    sample_html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>SEOWebChecker: Free SEO Audit & Analysis Tools</title>
        <meta name="description" content="Audit your website with SEOWebChecker for comprehensive SEO scoring, Core Web Vitals, and technical recommendations.">
        <link rel="canonical" href="https://seowebchecker.com/">
        <meta property="og:title" content="SEOWebChecker SEO Audit">
        <meta property="og:image" content="https://seowebchecker.com/logo.png">
    </head>
    <body>
        <h1>Comprehensive SEO Audit Tools</h1>
        <p>Analyze performance, meta tags, and structured data.</p>
        <img src="banner.jpg" alt="SEO Analysis Dashboard">
    </body>
    </html>
    """

    result = audit_html(sample_html; url = "https://seowebchecker.com/")
    
    @test result.url == "https://seowebchecker.com/"
    @test result.score.overall >= 90
    @test result.score.grade == "A"
    @test result.errors == 0
    @test result.passed_checks >= 5
    @test haskey(result.metadata, "title")
    @test haskey(result.metadata, "description")
    @test haskey(result.metadata, "canonical")
    @test haskey(result.metadata, "h1")
    @test result.metadata["h1"] == "Comprehensive SEO Audit Tools"

    # Test error cases (empty html)
    empty_result = audit_html("<html><body></body></html>"; url = "https://example.com")
    @test empty_result.errors > 0
    @test empty_result.score.overall < 80
end
