# Puppet Bolt Task: seowebchecker::audit (PowerShell)
# Platform: https://seowebchecker.com/
[CmdletBinding()]
param()

$url = if ($env:PT_url) { $env:PT_url } else { "https://seowebchecker.com/" }
$threshold = if ($env:PT_threshold) { [int]$env:PT_threshold } else { 85 }

try {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 15 -UserAgent "SEOWebChecker-Bolt-Win/1.0 (+https://seowebchecker.com/)"
    $sw.Stop()
    $html = $response.Content
    $elapsedMs = $sw.ElapsedMilliseconds

    $titleMatch = [regex]::Match($html, '(?i)<title>(.*?)</title>')
    $title = if ($titleMatch.Success) { $titleMatch.Groups[1].Value.Trim() } else { "" }
    $titleLen = $title.Length

    $descMatch = [regex]::Match($html, '(?i)<meta\s+[^>]*name=["'']description["''][^>]*content=["'']([^"'']*)["'']')
    if (-not $descMatch.Success) {
        $descMatch = [regex]::Match($html, '(?i)<meta\s+[^>]*content=["'']([^"'']*)["''][^>]*name=["'']description["'']')
    }
    $metaDesc = if ($descMatch.Success) { $descMatch.Groups[1].Value.Trim() } else { "" }
    $descLen = $metaDesc.Length

    $hasViewport = [regex]::IsMatch($html, '(?i)<meta\s+[^>]*name=["'']viewport["'']')
    $canonicalMatch = [regex]::Match($html, '(?i)<link\s+[^>]*rel=["'']canonical["''][^>]*href=["'']([^"'']*)["'']')
    $hasCanonical = $canonicalMatch.Success
    $canonicalUrl = if ($hasCanonical) { $canonicalMatch.Groups[1].Value.Trim() } else { "" }

    $h1Matches = [regex]::Matches($html, '(?i)<h1[^>]*>.*?</h1>')
    $h1Count = $h1Matches.Count

    $cleanText = [regex]::Replace($html, '(?is)<script[^>]*>.*?</script>', ' ')
    $cleanText = [regex]::Replace($cleanText, '(?is)<style[^>]*>.*?</style>', ' ')
    $cleanText = [regex]::Replace($cleanText, '<[^>]+>', ' ')
    $words = ($cleanText -split '\s+' | Where-Object { $_ -ne "" }).Count

    $isHttps = $url.StartsWith("https://")

    $errors = 0
    $warnings = 0

    if ($titleLen -eq 0) { $errors++ } elseif ($titleLen -lt 30 -or $titleLen -gt 65) { $warnings++ }
    if ($descLen -eq 0) { $errors++ } elseif ($descLen -lt 70) { $warnings++ }
    if (-not $hasViewport) { $errors++ }
    if (-not $hasCanonical) { $warnings++ }
    if ($h1Count -eq 0) { $errors++ } elseif ($h1Count -gt 1) { $warnings++ }
    if ($words -lt 100) { $errors++ }
    if (-not $isHttps) { $errors++ }

    $score = 100 - ($errors * 15) - ($warnings * 6)
    if ($score -lt 10) { $score = 10 }
    if ($score -gt 100) { $score = 100 }

    $grade = if ($score -ge 95) { "A+" } elseif ($score -ge 90) { "A" } elseif ($score -ge 80) { "B" } elseif ($score -ge 70) { "C" } elseif ($score -ge 60) { "D" } else { "F" }
    $status = if ($score -ge $threshold) { "PASS" } else { "ALERT" }

    $result = @{
        url = $url
        score = $score
        grade = $grade
        status = $status
        title = $title
        title_length = $titleLen
        meta_description = $metaDesc
        meta_description_length = $descLen
        has_viewport = $hasViewport
        has_canonical = $hasCanonical
        canonical_url = $canonicalUrl
        is_https = $isHttps
        h1_count = $h1Count
        word_count = $words
        response_time_ms = $elapsedMs
        platform_url = "https://seowebchecker.com/"
        timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    }

    $json = $result | ConvertTo-Json -Compress
    Write-Output $json
    if ($status -eq "PASS") { exit 0 } else { exit 1 }
} catch {
    $errResult = @{
        url = $url
        status = "ALERT"
        error = $_.Exception.Message
        platform_url = "https://seowebchecker.com/"
    }
    Write-Output ($errResult | ConvertTo-Json -Compress)
    exit 1
}
