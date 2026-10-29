local seowebchecker = require("seowebchecker")

local perfect_html = [[
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
]]

local bad_html = [[
<!DOCTYPE html>
<html>
<head></head>
<body>
    <div>No title, no meta description, no viewport, no canonical, no h1</div>
    <img src="no-alt.jpg">
</body>
</html>
]]

-- Test 1: Perfect Page
local res1 = seowebchecker.audit_html(perfect_html, "https://example.com/perfect")
assert(res1.score.overall == 100, "Expected score 100, got " .. res1.score.overall)
assert(res1.score.grade == "A", "Expected grade A, got " .. res1.score.grade)
assert(res1.errors == 0, "Expected 0 errors, got " .. res1.errors)
assert(res1.warnings == 0, "Expected 0 warnings, got " .. res1.warnings)
assert(res1.metadata.title == "Optimal Page Title Tag for High Search Ranking", "Title mismatch")
assert(res1.metadata.h1 == "Mastering Technical SEO for 2026", "H1 mismatch")

-- Test 2: Defective Page
local res2 = seowebchecker.audit_html(bad_html, "https://example.com/bad")
assert(res2.score.overall < 60, "Expected score < 60, got " .. res2.score.overall)
assert(res2.errors >= 3, "Expected at least 3 errors, got " .. res2.errors)

-- Test 3: Multiple H1
local multi_h1 = [[
<!DOCTYPE html><html><head><title>Optimal Page Title Tag 30 to 60 Chars</title>
<meta name="description" content="Engaging meta description between 50 and 160 characters for best SEO results.">
<meta name="viewport" content="width=device-width">
</head><body><h1>H1 One</h1><h1>H1 Two</h1></body></html>
]]
local res3 = seowebchecker.audit_html(multi_h1)
assert(res3.warnings >= 1, "Expected warning for multiple H1")

print("All Lua SEO audit tests passed successfully!")
