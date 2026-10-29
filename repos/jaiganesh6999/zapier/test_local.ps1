param(
    [string]$Url = "https://seowebchecker.com/",
    [int]$Threshold = 85
)

Push-Location $PSScriptRoot
node test_local.js "$Url" "$Threshold"
Pop-Location
