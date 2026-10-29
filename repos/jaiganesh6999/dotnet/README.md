# SeoWebChecker.SeoAudit (.NET / NuGet)

[![NuGet Version](https://img.shields.io/nuget/v/SeoWebChecker.SeoAudit.svg)](https://www.nuget.org/packages/SeoWebChecker.SeoAudit/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Official Site](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)

Lightweight open-source .NET client SDK for full website SEO audits, technical analysis, and Core Web Vitals diagnostics.

Official website: **[https://seowebchecker.com/](https://seowebchecker.com/)**

## Installation

Install via NuGet Package Manager:

```bash
dotnet add package SeoWebChecker.SeoAudit
```

Or via Package Manager Console:

```powershell
Install-Package SeoWebChecker.SeoAudit
```

## Quick Start (C#)

```csharp
using SeoWebChecker.SeoAudit;

var auditor = new SEOAuditor();

// Audit any live website asynchronously
var result = await auditor.AuditAsync("https://example.com");

Console.WriteLine($"Score: {result.Score.Overall}/100 (Grade: {result.Score.Grade})");
Console.WriteLine($"Passed: {result.Stats["passed"]}, Errors: {result.Stats["errors"]}");

foreach (var issue in result.Issues)
{
    if (issue.Severity == "error")
    {
        Console.WriteLine($"[ERROR] {issue.Title}: {issue.Recommendation}");
    }
}
```

## Audit HTML Strings Directly (ASP.NET Core, Blazor, SSR)

```csharp
var result = auditor.AuditHtml(renderedHtml, "https://seowebchecker.com/");
Console.WriteLine($"Score: {result.Score.Overall}");
```

## License

MIT License © 2026 [SEOWebChecker](https://seowebchecker.com/).
