# Quickstart Guide

This guide shows how to quickly get started with the **SEOWebChecker SEO Audit SDK** across major ecosystems.

Official Website: **[https://seowebchecker.com/](https://seowebchecker.com/)**

---

## 🐍 Python

### Installation
```bash
pip install seowebchecker-seoaudit-sdk
```

### Usage
```python
from seowebchecker_seoaudit import SEOAuditor

auditor = SEOAuditor()
result = auditor.audit_url("https://seowebchecker.com/")

print(f"Overall SEO Score: {result.score.overall}/100")
print(f"Total Issues Found: {len(result.issues)}")
for issue in result.issues:
    print(f"[{issue.severity.upper()}] {issue.title}: {issue.description}")
```

---

## 📦 Node.js / TypeScript

### Installation
```bash
npm install seowebchecker-seoaudit-sdk
# or
yarn add seowebchecker-seoaudit-sdk
```

### Usage
```typescript
import { SEOAuditor } from 'seowebchecker-seoaudit-sdk';

const auditor = new SEOAuditor();
const report = await auditor.auditUrl('https://seowebchecker.com/');

console.log(`SEO Score: ${report.score.overall}/100`);
console.log(`Passed Checks: ${report.score.passedChecks}`);
```

---

## 🐘 PHP (8.2+)

### Installation
```bash
composer require seowebchecker/seoaudit-sdk
```

### Usage
```php
<?php
require_once __DIR__ . '/vendor/autoload.php';

use SeoWebChecker\SEOAuditor;

$auditor = new SEOAuditor();
$result = $auditor->auditUrl('https://seowebchecker.com/');

echo "Overall SEO Score: " . $result->score->overall . "/100\n";
```

---

## 🔷 .NET / C#

### Installation
```bash
dotnet add package SeoWebChecker.SeoAudit
```

### Usage
```csharp
using SeoWebChecker.SeoAudit;

var auditor = new SEOAuditor();
var result = await auditor.AuditUrlAsync("https://seowebchecker.com/");

Console.WriteLine($"SEO Score: {result.Score.Overall}/100");
```

---

## ☕ Java

### Maven
```xml
<dependency>
    <groupId>com.seowebchecker</groupId>
    <artifactId>seowebchecker-seoaudit-sdk</artifactId>
    <version>1.0.0</version>
</dependency>
```

### Usage
```java
import com.seowebchecker.SEOAuditor;
import com.seowebchecker.AuditResult;

SEOAuditor auditor = new SEOAuditor();
AuditResult result = auditor.auditUrl("https://seowebchecker.com/");

System.out.println("SEO Score: " + result.getScore().getOverall());
```

---

## 🐳 Docker CLI

Run a full audit against any URL without local SDK installations:
```bash
docker run --rm ghcr.io/jaiganesh6999/seowebchecker-seoaudit-sdk:latest python -m seowebchecker_seoaudit.cli https://seowebchecker.com/
```
