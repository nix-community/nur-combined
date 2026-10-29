# seowebchecker-seoaudit-sdk (Java / Maven Central)

[![Maven Central](https://img.shields.io/maven-central/v/com.seowebchecker/seowebchecker-seoaudit-sdk.svg)](https://central.sonatype.com/artifact/com.seowebchecker/seowebchecker-seoaudit-sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Official Site](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)

Lightweight open-source Java client SDK for website SEO audits, technical analysis, and Core Web Vitals diagnostics.

Official website: **[https://seowebchecker.com/](https://seowebchecker.com/)**

## Maven Dependency

```xml
<dependency>
    <groupId>com.seowebchecker</groupId>
    <artifactId>seowebchecker-seoaudit-sdk</artifactId>
    <version>1.0.0</version>
</dependency>
```

## Gradle

```groovy
implementation 'com.seowebchecker:seowebchecker-seoaudit-sdk:1.0.0'
```

## Quick Start (Java)

```java
import com.seowebchecker.SEOAuditor;
import com.seowebchecker.AuditResult;

public class Main {
    public static void main(String[] args) throws Exception {
        SEOAuditor auditor = new SEOAuditor();
        AuditResult result = auditor.audit("https://example.com");

        System.out.println("Overall Score: " + result.getOverallScore() + "/100 (Grade: " + result.getGrade() + ")");
        System.out.println("Passed: " + result.getPassedCount() + ", Errors: " + result.getErrorCount());
    }
}
```

## License

MIT License © 2026 [SEOWebChecker](https://seowebchecker.com/).
