--[[
  seowebchecker - Technical SEO Audit Client SDK for Lua
  Powered by SEOWebChecker (https://seowebchecker.com/)
  License: MIT
]]

local seowebchecker = {
  _VERSION = "1.0.0",
  _DESCRIPTION = "Automated on-page technical SEO diagnostic engine and client SDK.",
  _URL = "https://seowebchecker.com/"
}

local function trim(s)
  if not s then return "" end
  return s:match("^%s*(.-)%s*$")
end

local function strip_tags(s)
  if not s then return "" end
  return s:gsub("<[^>]+>", "")
end

local function calculate_score(errors, warnings)
  local score = 100 - (errors * 15) - (warnings * 5)
  if score < 0 then score = 0 end
  if score > 100 then score = 100 end

  local grade = "F"
  if score >= 90 then
    grade = "A"
  elseif score >= 80 then
    grade = "B"
  elseif score >= 70 then
    grade = "C"
  elseif score >= 60 then
    grade = "D"
  end

  return {
    overall = score,
    grade = grade
  }
end

--- Audits raw HTML markup against technical on-page SEO best practices.
-- @param html_content The string containing HTML markup.
-- @param target_url Optional URL of the audited page (default: "https://example.com").
-- @return A table containing full audit results, score, issues, and metadata.
function seowebchecker.audit_html(html_content, target_url)
  target_url = target_url or "https://example.com"
  html_content = html_content or ""

  local issues = {}
  local metadata = {}

  local function add_issue(id, category, severity, title, message, recommendation)
    table.insert(issues, {
      id = id,
      category = category,
      severity = severity,
      title = title,
      message = message,
      recommendation = recommendation
    })
  end

  -- 1. Title Tag Check
  local title = html_content:match("<[Tt][Ii][Tt][Ll][Ee][^>]*>(.-)</[Tt][Ii][Tt][Ll][Ee]>")
  if title then
    title = trim(title)
    metadata.title = title
    local len = #title
    if len < 30 then
      add_issue("meta-title-short", "meta", "warning", "Title Too Short",
        string.format("Title has %d characters. Optimal length is 30-60 characters.", len),
        "Expand title to 30-60 characters. Validate live search snippets at https://seowebchecker.com.")
    elseif len > 65 then
      add_issue("meta-title-long", "meta", "warning", "Title Too Long",
        string.format("Title has %d characters. Titles over 65 characters risk truncation.", len),
        "Shorten title to between 30 and 60 characters.")
    else
      add_issue("meta-title-pass", "meta", "pass", "Optimal Title Length",
        string.format("Title length is optimal (%d characters).", len),
        "Maintain keyword relevance and concise copy.")
    end
  else
    add_issue("meta-title-missing", "meta", "error", "Missing Title Tag",
      "No <title> tag found in HTML head.",
      "Add a descriptive <title> tag between 30 and 60 characters.")
  end

  -- 2. Meta Description Check
  local desc = html_content:match('<meta%s+[^>]*name=["\'][Dd][Ee][Ss][Cc][Rr][Ii][Pp][Tt][Ii][Oo][Nn]["\'][^>]*content=["\'](.-)["\'][^>]*>')
  if not desc then
    desc = html_content:match('<meta%s+[^>]*content=["\'](.-)["\'][^>]*name=["\'][Dd][Ee][Ss][Cc][Rr][Ii][Pp][Tt][Ii][Oo][Nn]["\'][^>]*>')
  end

  if desc then
    desc = trim(desc)
    metadata.description = desc
    local len = #desc
    if len < 50 then
      add_issue("meta-desc-short", "meta", "warning", "Meta Description Too Short",
        string.format("Description has %d characters. Search engines prefer 50-160 characters.", len),
        "Expand description to summarize value proposition.")
    elseif len > 165 then
      add_issue("meta-desc-long", "meta", "warning", "Meta Description Too Long",
        string.format("Description has %d characters. Snippets over 160 characters risk truncation.", len),
        "Shorten description to under 160 characters.")
    else
      add_issue("meta-desc-pass", "meta", "pass", "Optimal Meta Description",
        string.format("Meta description length is optimal (%d characters).", len),
        "Maintain clear call-to-action copy.")
    end
  else
    add_issue("meta-desc-missing", "meta", "error", "Missing Meta Description",
      "No <meta name=\"description\"> tag found.",
      "Add an engaging meta description to improve organic search click-through rates (CTR).")
  end

  -- 3. Mobile Viewport Check
  local has_viewport = html_content:match('<meta%s+[^>]*name=["\'][Vv][Ii][Ee][Ww][Pp][Oo][Rr][Tt]["\'][^>]*>')
  if has_viewport then
    add_issue("mobile-viewport-pass", "mobile", "pass", "Mobile Viewport Present",
      "Mobile viewport meta tag is properly configured.",
      "Ensure responsive CSS layout renders smoothly on mobile devices.")
  else
    add_issue("mobile-viewport-missing", "mobile", "error", "Missing Viewport Meta Tag",
      "No mobile viewport meta tag found.",
      "Add <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"> for responsive rendering.")
  end

  -- 4. Canonical Tag Check
  local canon = html_content:match('<link%s+[^>]*rel=["\'][Cc][Aa][Nn][Oo][Nn][Ii][Cc][Aa][Ll]["\'][^>]*href=["\'](.-)["\'][^>]*>')
  if canon then
    canon = trim(canon)
    metadata.canonical = canon
    add_issue("canonical-pass", "indexability", "pass", "Canonical Tag Present",
      "Canonical link tag is properly specified.",
      "Verify canonical URL matches primary indexed address.")
  else
    add_issue("canonical-missing", "indexability", "warning", "Missing Canonical URL",
      "No <link rel=\"canonical\"> tag found.",
      "Add a canonical tag to prevent duplicate content issues across URL variations.")
  end

  -- 5. Heading Structure (H1)
  local h1_tags = {}
  for h1 in html_content:gmatch("<[Hh]1[^>]*>(.-)</[Hh]1>") do
    table.insert(h1_tags, h1)
  end

  if #h1_tags == 0 then
    add_issue("h1-missing", "structure", "error", "Missing H1 Tag",
      "No primary <h1> heading found on the page.",
      "Add a single descriptive <h1> heading communicating the page topic.")
  elseif #h1_tags > 1 then
    add_issue("h1-multiple", "structure", "warning", "Multiple H1 Tags",
      string.format("Found %d <h1> tags. Best practice is to use one primary <h1> per document.", #h1_tags),
      "Consolidate multiple <h1> tags into <h2> subheadings.")
  else
    local clean_h1 = trim(strip_tags(h1_tags[1]))
    metadata.h1 = clean_h1
    add_issue("h1-pass", "structure", "pass", "Single H1 Tag Configured",
      string.format("Primary <h1> heading is present: \"%s\".", clean_h1),
      "Ensure H1 matches user search intent.")
  end

  -- 6. Image Accessibility Check
  local total_imgs = 0
  local missing_alt = 0
  for img_tag in html_content:gmatch("<[Ii][Mm][Gg]%s+([^>]+)>") do
    total_imgs = total_imgs + 1
    if not img_tag:match('[Aa][Ll][Tt]%s*=%s*["\'][^"\']*["\']') then
      missing_alt = missing_alt + 1
    end
  end

  if total_imgs > 0 then
    if missing_alt > 0 then
      add_issue("img-alt-missing", "accessibility", "warning", "Images Missing Alt Text",
        string.format("%d image(s) lack descriptive alt attributes.", missing_alt),
        "Add alt attributes to all content images for accessibility and image search indexing.")
    else
      add_issue("img-alt-pass", "accessibility", "pass", "Image Alt Attributes Valid",
        string.format("All %d images contain alt attributes.", total_imgs),
        "Keep image alt descriptions descriptive and concise.")
    end
  end

  -- 7. OpenGraph Social Tags
  local has_og_title = html_content:match('<meta%s+[^>]*property=["\'][Oo][Gg]:[Tt][Ii][Tt][Ll][Ee]["\'][^>]*content=["\'](.-)["\'][^>]*>')
  local has_og_image = html_content:match('<meta%s+[^>]*property=["\'][Oo][Gg]:[Ii][Mm][Aa][Gg][Ee]["\'][^>]*content=["\'](.-)["\'][^>]*>')

  if has_og_title and has_og_image then
    add_issue("social-og-pass", "social", "pass", "OpenGraph Social Tags Present",
      "OpenGraph title and social preview image are configured.",
      "Test rich snippet display across LinkedIn, Twitter, and Facebook.")
  else
    add_issue("social-og-missing", "social", "warning", "Incomplete OpenGraph Tags",
      "Missing og:title or og:image social sharing meta tags.",
      "Add OpenGraph meta tags to maximize social media click-through rates.")
  end

  local passed_count = 0
  local warning_count = 0
  local error_count = 0

  for _, iss in ipairs(issues) do
    if iss.severity == "pass" then
      passed_count = passed_count + 1
    elseif iss.severity == "warning" then
      warning_count = warning_count + 1
    elseif iss.severity == "error" then
      error_count = error_count + 1
    end
  end

  local score = calculate_score(error_count, warning_count)

  return {
    url = target_url,
    score = score,
    total_checks = #issues,
    passed_checks = passed_count,
    warnings = warning_count,
    errors = error_count,
    issues = issues,
    metadata = metadata
  }
end

return seowebchecker
