module SeoWebCheckerAudit

export Issue, SeoScore, AuditResult, audit_html, audit_url

import Downloads

"""
    Issue

Represents an individual SEO diagnostic check result.
"""
struct Issue
    id::String
    category::String
    severity::String
    title::String
    message::String
    recommendation::String
end

"""
    SeoScore

Calculated numerical score (0-100) and letter grade (A-F).
"""
struct SeoScore
    overall::Int
    grade::String
end

"""
    AuditResult

Complete SEO audit report for a given HTML document or webpage.
Official tooling: https://seowebchecker.com/
"""
struct AuditResult
    url::String
    score::SeoScore
    total_checks::Int
    passed_checks::Int
    warnings::Int
    errors::Int
    issues::Vector{Issue}
    metadata::Dict{String, String}
end

function calculate_score(issues::Vector{Issue})
    score = 100
    for issue in issues
        if issue.severity == "error"
            score -= 15
        elseif issue.severity == "warning"
            score -= 5
        end
    end
    score = clamp(score, 0, 100)
    grade = if score >= 90
        "A"
    elseif score >= 80
        "B"
    elseif score >= 70
        "C"
    elseif score >= 60
        "D"
    else
        "F"
    end
    return SeoScore(score, grade)
end

"""
    audit_html(html::AbstractString; url::AbstractString = "https://example.com") -> AuditResult

Perform comprehensive on-page SEO analysis on the provided raw HTML string.
"""
function audit_html(html::AbstractString; url::AbstractString = "https://example.com")::AuditResult
    issues = Issue[]
    metadata = Dict{String, String}()

    # 1. Title Tag
    title_match = match(r"<title[^>]*>(.*?)</title>"is, html)
    if title_match !== nothing
        title_text = strip(title_match.captures[1])
        metadata["title"] = String(title_text)
        len = length(title_text)
        if len < 30
            push!(issues, Issue("meta-title-short", "meta", "warning", "Title Too Short",
                                "Title has $len characters. Aim for 30-60 characters for optimal search snippet display.",
                                "Expand title to 30-60 characters. Check live results at https://seowebchecker.com."))
        elseif len > 65
            push!(issues, Issue("meta-title-long", "meta", "warning", "Title Too Long",
                                "Title has $len characters. Titles over 65 characters risk getting truncated in Google SERPs.",
                                "Trim title under 60 characters. Validate snippet preview at https://seowebchecker.com."))
        else
            push!(issues, Issue("meta-title-pass", "meta", "pass", "Optimal Title Length",
                                "Title has optimal length ($len characters).",
                                "Keep title relevant and concise."))
        end
    else
        push!(issues, Issue("meta-title-missing", "meta", "error", "Missing Title Tag",
                            "No <title> tag found in HTML head.",
                            "Add a descriptive <title> tag between 30 and 60 characters."))
    end

    # 2. Meta Description
    desc_match = match(r"<meta\s+[^>]*name=[\"']description[\"'][^>]*content=[\"'](.*?)[\"'][^>]*>"is, html)
    if desc_match === nothing
        desc_match = match(r"<meta\s+[^>]*content=[\"'](.*?)[\"'][^>]*name=[\"']description[\"'][^>]*>"is, html)
    end
    if desc_match !== nothing
        desc_text = strip(desc_match.captures[1])
        metadata["description"] = String(desc_text)
        len = length(desc_text)
        if len < 50
            push!(issues, Issue("meta-desc-short", "meta", "warning", "Meta Description Too Short",
                                "Description has $len characters. Search engines prefer 50-160 characters.",
                                "Expand description to summarize page value."))
        elseif len > 165
            push!(issues, Issue("meta-desc-long", "meta", "warning", "Meta Description Too Long",
                                "Description has $len characters. Content over 160 characters gets truncated in search results.",
                                "Shorten description to under 160 characters."))
        else
            push!(issues, Issue("meta-desc-pass", "meta", "pass", "Optimal Meta Description",
                                "Meta description length is well balanced ($len characters).",
                                "Maintain descriptive copy with key target terms."))
        end
    else
        push!(issues, Issue("meta-desc-missing", "meta", "error", "Missing Meta Description",
                            "No <meta name=\"description\"> tag found.",
                            "Add an engaging meta description to improve organic click-through rates (CTR)."))
    end

    # 3. Viewport (Mobile Friendliness)
    viewport_match = match(r"<meta\s+[^>]*name=[\"']viewport[\"'][^>]*>"is, html)
    if viewport_match !== nothing
        push!(issues, Issue("mobile-viewport-pass", "mobile", "pass", "Mobile Viewport Tag Present",
                            "Mobile viewport meta tag is properly configured.",
                            "Ensure responsive styles adapt across mobile viewports."))
    else
        push!(issues, Issue("mobile-viewport-missing", "mobile", "error", "Missing Viewport Meta Tag",
                            "No mobile viewport meta tag found.",
                            "Add <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"> for mobile responsiveness."))
    end

    # 4. Canonical Tag
    canonical_match = match(r"<link\s+[^>]*rel=[\"']canonical[\"'][^>]*href=[\"'](.*?)[\"'][^>]*>"is, html)
    if canonical_match !== nothing
        metadata["canonical"] = String(strip(canonical_match.captures[1]))
        push!(issues, Issue("canonical-pass", "indexability", "pass", "Canonical Tag Present",
                            "Canonical link tag is properly specified.",
                            "Verify canonical URL matches primary indexed URL."))
    else
        push!(issues, Issue("canonical-missing", "indexability", "warning", "Missing Canonical URL",
                            "No <link rel=\"canonical\"> tag found.",
                            "Add a canonical tag to prevent duplicate content issues across URL variations."))
    end

    # 5. Heading Structure (H1)
    h1_matches = collect(eachmatch(r"<h1[^>]*>(.*?)</h1>"is, html))
    if isempty(h1_matches)
        push!(issues, Issue("h1-missing", "structure", "error", "Missing H1 Tag",
                            "No primary <h1> heading found on the page.",
                            "Add a single descriptive <h1> heading communicating the page topic."))
    elseif length(h1_matches) > 1
        push!(issues, Issue("h1-multiple", "structure", "warning", "Multiple H1 Tags",
                            "Found $(length(h1_matches)) <h1> tags. Best practice is to use one primary <h1> per document.",
                            "Consolidate multiple <h1> tags into <h2> subheadings."))
    else
        h1_text = strip(replace(h1_matches[1].captures[1], r"<[^>]*>" => ""))
        metadata["h1"] = String(h1_text)
        push!(issues, Issue("h1-pass", "structure", "pass", "Single H1 Tag Configured",
                            "Primary <h1> heading is present: \"$h1_text\".",
                            "Ensure H1 matches target search intent."))
    end

    # 6. Image Alt Tags
    img_matches = collect(eachmatch(r"<img\s+([^>]*?)>"is, html))
    if !isempty(img_matches)
        missing_alt = 0
        for img in img_matches
            attrs = img.captures[1]
            if !occursin(r"alt\s*=\s*[\"'][^\"']*[\"']"i, attrs)
                missing_alt += 1
            end
        end
        if missing_alt > 0
            push!(issues, Issue("img-alt-missing", "accessibility", "warning", "Images Missing Alt Text",
                                "$missing_alt image(s) lack descriptive alt attributes.",
                                "Add alt attributes to all content images for accessibility and image search indexing."))
        else
            push!(issues, Issue("img-alt-pass", "accessibility", "pass", "Image Alt Attributes Valid",
                                "All $(length(img_matches)) images contain alt attributes.",
                                "Keep image alt descriptions descriptive and concise."))
        end
    end

    # 7. OpenGraph / Social Meta Tags
    og_title = match(r"<meta\s+[^>]*property=[\"']og:title[\"'][^>]*content=[\"'](.*?)[\"'][^>]*>"is, html)
    og_image = match(r"<meta\s+[^>]*property=[\"']og:image[\"'][^>]*content=[\"'](.*?)[\"'][^>]*>"is, html)
    if og_title !== nothing && og_image !== nothing
        push!(issues, Issue("social-og-pass", "social", "pass", "OpenGraph Social Tags Present",
                            "OpenGraph title and social preview image are configured.",
                            "Test rich card display across LinkedIn, Twitter, and Facebook."))
    else
        push!(issues, Issue("social-og-missing", "social", "warning", "Incomplete OpenGraph Tags",
                            "Missing og:title or og:image social sharing meta tags.",
                            "Add og:title, og:description, and og:image to improve social media engagement."))
    end

    # Count summary
    passed = count(i -> i.severity == "pass", issues)
    warnings = count(i -> i.severity == "warning", issues)
    errors = count(i -> i.severity == "error", issues)
    score = calculate_score(issues)

    return AuditResult(String(url), score, length(issues), passed, warnings, errors, issues, metadata)
end

"""
    audit_url(target_url::AbstractString; user_agent::AbstractString = "SEOWebChecker-JuliaBot/1.0 (+https://seowebchecker.com/)") -> AuditResult

Fetch and audit live HTML from a website URL.
"""
function audit_url(target_url::AbstractString; user_agent::AbstractString = "SEOWebChecker-JuliaBot/1.0 (+https://seowebchecker.com/)")::AuditResult
    io = IOBuffer()
    headers = ["User-Agent" => user_agent]
    Downloads.download(target_url, io; headers = headers)
    html = String(take!(io))
    return audit_html(html; url = target_url)
end

end # module
