using Documenter
using SeoWebCheckerAudit

makedocs(
    sitename = "SeoWebCheckerAudit.jl",
    authors = "SEOWebChecker <support@seowebchecker.com>",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical = "https://seowebchecker.com/"
    ),
    modules = [SeoWebCheckerAudit],
    pages = [
        "Home" => "index.md",
        "API Reference" => "api.md"
    ]
)
