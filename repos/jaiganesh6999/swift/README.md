# SeoWebChecker (Swift & CocoaPods)

[![CocoaPods](https://img.shields.io/cocoapods/v/SeoWebChecker.svg)](https://cocoapods.org/pods/SeoWebChecker)
[![Platform](https://img.shields.io/cocoapods/p/SeoWebChecker.svg)](https://cocoapods.org/pods/SeoWebChecker)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Official Site](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)

A lightweight Swift client SDK and on-page technical SEO diagnostic engine for iOS, macOS, watchOS, and tvOS.

Powered by **[SEOWebChecker.com](https://seowebchecker.com/)**.

---

## Installation

### CocoaPods

Add the following line to your `Podfile`:

```ruby
pod 'SeoWebChecker', '~> 1.0.0'
```

Then run:

```bash
pod install
```

### Swift Package Manager (SPM)

In Xcode, select **File > Add Package Dependencies...** and enter:

```text
https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk
```

---

## Quick Start

### 1. In-Memory HTML Audit

```swift
import SeoWebChecker

let html = """
<!DOCTYPE html>
<html>
<head>
    <title>High Ranking On-Page SEO Checklist & Guide</title>
    <meta name="description" content="Master technical on-page SEO, heading structure, and Core Web Vitals optimization.">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="canonical" href="https://example.com/guide">
</head>
<body>
    <h1>On-Page Technical SEO Essentials</h1>
</body>
</html>
"""

let result = SeoWebChecker.auditHTML(html, url: "https://example.com/guide")

print("Overall Score: \(result.score.overall)/100 (Grade \(result.score.grade))")
print("Passed Checks: \(result.passedChecks)/\(result.totalChecks)")
print("Warnings: \(result.warnings), Errors: \(result.errors)")
```

### 2. Live Web Crawl & Audit (Async / Await)

```swift
import SeoWebChecker

Task {
    do {
        let result = try await SeoWebChecker.auditURL(URL(string: "https://example.com")!)
        print("Score: \(result.score.overall)/100 (Grade \(result.score.grade))")
    } catch {
        print("Audit failed: \(error)")
    }
}
```

---

## Online Tools

- **Official Website & Free Online Tools**: [https://seowebchecker.com/](https://seowebchecker.com/)

---

## License

MIT © 2026 [SEOWebChecker.com](https://seowebchecker.com/).
