# SEOWebChecker - Eclipse IDE Plugin & Marketplace Solution

[![Platform](https://img.shields.io/badge/Platform-seowebchecker.com-brightgreen)](https://seowebchecker.com/)
[![Eclipse Marketplace](https://img.shields.io/badge/Eclipse%20Marketplace-Solution-blue.svg)](https://marketplace.eclipse.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Official [Eclipse IDE](https://www.eclipse.org/) plugin and Marketplace solution for **SEOWebChecker**. Brings real-time on-page technical SEO diagnostics, heading structure validation, Core Web Vitals checks, and image accessibility auditing directly into the Eclipse IDE and Eclipse Theia.

Powered by the [SEOWebChecker](https://seowebchecker.com/) platform.

---

## ⚡ Plugin Features in Eclipse IDE

* **Real-Time On-Page Analysis**: Inspects HTML, JSP, JSF, PHP, React templates, and Markdown.
* **Title & Meta Tag Linter**: Flags missing `<title>` tags, detects snippet truncation risk (< 30 or > 60 characters), and validates meta descriptions (70–160 characters).
* **Heading Hierarchy & Duplicate H1s**: Validates `<h1>` document structure and alerts if multiple H1 tags are present.
* **Mobile Viewport & Accessibility**: Validates `<meta name="viewport">` and audits `<img>` tags for missing `alt` attributes.
* **Canonical & OpenGraph**: Ensures presence of `<link rel="canonical">` and social preview cards (`og:title`, `og:image`).
* **Dynamic Scoring**: Computes a 0–100 score and letter grade (`A+` through `F`).

---

## 📋 Eclipse Marketplace Listing Guide (`marketplace.eclipse.org`)

To publish SEOWebChecker on the **Eclipse Marketplace**, go to **[https://marketplace.eclipse.org/node/add/solution](https://marketplace.eclipse.org/node/add/solution)** and use the following details:

### 1. Basic Information
* **Title**:
  ```text
  SEOWebChecker - Technical SEO Audit & Analyzer
  ```
* **Short Description**:
  ```text
  Real-time technical SEO auditing tool for HTML, JSP, JSF, PHP, React, and Markdown. Validates meta tags, duplicate H1s, image alt text, and Core Web Vitals.
  ```
* **Organization / Publisher**:
  ```text
  SEOWebChecker
  ```
* **Status**:
  ```text
  Production/Stable
  ```
* **License**:
  ```text
  MIT License
  ```

---

### 2. Markets, Categories & Tags
* **Markets**:
  * `Web, XML, Java EE and OSGi Enterprise Development`
  * `Tools`
  * `Source Code Analyzers`
* **Categories**:
  * `Editor`
  * `Testing`
* **Tags**:
  ```text
  seo, seo-audit, html, linter, accessibility, web-development, core-web-vitals
  ```

---

### 3. URLs & Update Site
* **Update Site URL (P2 Repository)**:
  ```text
  https://jaiganesh6999.github.io/seowebchecker-seoaudit-sdk/eclipse/update-site/
  ```
* **Home Page URL**:
  ```text
  https://seowebchecker.com/
  ```
* **Source Code / Repository URL**:
  ```text
  https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk
  ```
* **Documentation URL**:
  ```text
  https://seo-ai-tools.readthedocs.io/en/latest/
  ```
* **Support URL / Issue Tracker**:
  ```text
  https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/issues
  ```
* **Open VSX / Eclipse Theia Extension Link**:
  ```text
  https://open-vsx.org/extension/seo-audit-tool/seowebchecker
  ```

---

### 4. Detailed Description (HTML / Body for Eclipse Marketplace)

```html
<p><strong>SEOWebChecker for Eclipse IDE</strong> brings real-time on-page technical SEO diagnostics, heading structure validation, image accessibility auditing, and Core Web Vitals checks directly into your code editor.</p>

<h3>Key Features:</h3>
<ul>
  <li><strong>Title &amp; Meta Description Inspector:</strong> Detects missing tags and alerts against length truncation thresholds.</li>
  <li><strong>Heading Hierarchy &amp; Duplicate H1 Detection:</strong> Validates presence of exactly one primary H1 heading and alerts on duplicate H1 tags.</li>
  <li><strong>Image Accessibility (Alt Attributes):</strong> Audits all image elements for missing or redundant alt descriptions.</li>
  <li><strong>Mobile Viewport &amp; Canonical Tags:</strong> Ensures mobile-friendly viewports and self-referential canonical link tags are configured.</li>
  <li><strong>OpenGraph Social Preview Cards:</strong> Verifies og:title and og:image tags for rich preview snippets across social networks.</li>
  <li><strong>1-Click Audit Execution:</strong> Right-click any file in your Project Explorer and select <em>SEOWebChecker: Run Technical SEO Audit</em>.</li>
</ul>

<p>Powered by the <a href="https://seowebchecker.com/">SEOWebChecker</a> technical SEO analysis platform.</p>
```

---

## 🛠️ Building the Plugin from Source

Requirements: Java 17+ and Apache Maven 3.8+.

```bash
cd eclipse
mvn clean install
```
The compiled OSGi bundle `.jar` will be generated in `eclipse/target/com.seowebchecker.seoaudit-1.0.0.jar`.

---

## 📄 License

MIT License. Engineered by the [SEOWebChecker](https://seowebchecker.com/) team.
