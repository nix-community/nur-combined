# net.clojars.seoaitools/seowebchecker-seoaudit-sdk (Clojure)

[![Official Website](https://img.shields.io/badge/Website-seowebchecker.com-blue?style=flat-square)](https://seowebchecker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Clojars Project](https://img.shields.io/clojars/v/net.clojars.seoaitools/seowebchecker-seoaudit-sdk.svg)](https://clojars.org/net.clojars.seoaitools/seowebchecker-seoaudit-sdk)

Lightweight open-source client SDK and utility suite for automated on-page technical SEO audits, meta tag validations, heading structure inspections, image accessibility analysis, and Core Web Vitals checks for the Clojure programming language. Engineered by the [SEOWebChecker](https://seowebchecker.com/) team.

Full web-based audits, interactive reports, and live SEO benchmarks are available at **[https://seowebchecker.com/](https://seowebchecker.com/)**.

---

## ⚡ Features

- **Zero Heavy Dependencies**: Built solely upon pure Clojure and modern JVM standard libraries (`java.net.http.HttpClient`).
- **Comprehensive Technical Checks**:
  - Title tag length verification (30–60 characters).
  - Meta description inspection (50–160 characters).
  - Mobile viewport tag detection.
  - Canonical URL link checking.
  - Primary single `<h1>` tag integrity.
  - Missing image `alt` attributes.
  - OpenGraph social sharing meta tags (`og:title`, `og:image`).
- **Scoring Engine**: Generates an actionable 0–100 score and letter grade (A–F) with explicit recommendations.

---

## 📦 Installation

Add the dependency to your Clojure project:

### Leiningen (`project.clj`)
```clojure
[net.clojars.seoaitools/seowebchecker-seoaudit-sdk "1.0.0"]
```

### Clojure CLI (`deps.edn`)
```clojure
net.clojars.seoaitools/seowebchecker-seoaudit-sdk {:mvn/version "1.0.0"}
```

---

## 🚀 Quickstart

### Audit an HTML String

```clojure
(ns my-app.core
  (:require [seowebchecker.seoaudit :as audit]))

(def sample-html
  "<!DOCTYPE html><html><head>
     <title>SEOWebChecker: Free SEO Audit & Analysis Tools</title>
     <meta name='description' content='Audit your website for comprehensive SEO scoring.'>
     <meta name='viewport' content='width=device-width, initial-scale=1.0'>
     <link rel='canonical' href='https://seowebchecker.com/'>
   </head><body>
     <h1>Comprehensive SEO Audit Tools</h1>
     <img src='banner.jpg' alt='Dashboard preview'>
   </body></html>")

(let [result (audit/audit-html sample-html :url "https://seowebchecker.com/")]
  (println "Score:" (get-in result [:score :overall]) "/ 100")
  (println "Grade:" (get-in result [:score :grade]))
  (println "Passed:" (:passed-checks result) "/" (:total-checks result))
  (doseq [issue (:issues result)]
    (println "[" (:severity issue) "]" (:title issue) "-" (:message issue))))
```

### Audit a Live Website URL

```clojure
(let [result (audit/audit-url "https://seowebchecker.com/")]
  (println "URL:" (:url result))
  (println "Overall Score:" (get-in result [:score :overall]) "%")
  (println "Warnings:" (:warnings result))
  (println "Errors:" (:errors result)))
```

---

## 🔗 Related Resources

- **Official Web Portal**: [https://seowebchecker.com/](https://seowebchecker.com/)
- **GitHub Repository**: [https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk)
- **Clojars Registry**: [https://clojars.org/net.clojars.seoaitools/seowebchecker-seoaudit-sdk](https://clojars.org/net.clojars.seoaitools/seowebchecker-seoaudit-sdk)

---

## 📄 License

MIT License © 2026 [SEOWebChecker](https://seowebchecker.com/).
