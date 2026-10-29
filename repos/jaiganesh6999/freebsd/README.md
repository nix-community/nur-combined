# FreeBSD Ports Submission Guide: `www/seowebchecker`

This guide provides the exact steps to submit `seowebchecker` as an official new port in the **FreeBSD Ports Collection** via **FreeBSD Bugzilla**.

Canonical Homepage: [https://seowebchecker.com/](https://seowebchecker.com/)

---

## 📋 Submission Overview

| Field | Value |
| :--- | :--- |
| **Bugzilla URL** | [https://bugs.freebsd.org/bugzilla/enter_bug.cgi?product=Ports%20%26%20Packages](https://bugs.freebsd.org/bugzilla/enter_bug.cgi?product=Ports%20%26%20Packages) |
| **Product** | `Ports & Packages` |
| **Component** | `Individual Port(s)` |
| **Summary** | `[NEW PORT] www/seowebchecker: Lightweight website SEO audit tool and CLI` |
| **Severity** | `Affects Only Me` |
| **Class** | `change-request` |
| **Attachment** | [`seowebchecker.shar`](./seowebchecker.shar) (Shell Archive) |

---

## 🛠️ Step-by-Step Submission Instructions

### Step 1: Log in to FreeBSD Bugzilla
1. Go to [https://bugs.freebsd.org/bugzilla/](https://bugs.freebsd.org/bugzilla/).
2. Log in (or create a free account if you do not have one).

### Step 2: Open New Bug Form
Click on **New Bug** or go directly to:
👉 **[Enter New Port Bug](https://bugs.freebsd.org/bugzilla/enter_bug.cgi?product=Ports%20%26%20Packages)**

### Step 3: Fill in Form Fields

* **Product**: `Ports & Packages`
* **Component**: `Individual Port(s)`
* **Version**: `Latest`
* **Severity**: `Affects Only Me`
* **Summary**:
  ```text
  [NEW PORT] www/seowebchecker: Lightweight website SEO audit tool and CLI
  ```

* **Description**:
  ```text
  SEOWebChecker is an open-source technical SEO audit client and CLI tool
  for automated on-page technical SEO audits, meta tag validation, heading
  hierarchy verification, image accessibility tags, and Core Web Vitals checks.

  WWW: https://seowebchecker.com/

  QA:
  - portlint -A: clean (no errors, no warnings)
  - testbuild: builds and packages cleanly
  - package size: ~234 KB
  - runtime dependency: nodejs

  Please find the attached shar file (www/seowebchecker.shar) containing the port.
  ```

### Step 4: Attach the Shell Archive (`seowebchecker.shar`)
1. Click **Add an attachment**.
2. Select the file: [`freebsd/seowebchecker.shar`](./seowebchecker.shar) from this repository.
3. Description: `www/seowebchecker port shar archive`
4. Content-Type: `text/plain` (or `application/x-shar`)
5. Check: `patch` checkbox can be left unchecked or checked.

### Step 5: Submit Bug
Click **Submit Bug**!

Once submitted, FreeBSD Bugzilla will assign a PR number (e.g. `ports/281xxx`) and FreeBSD Ports committers will review and commit `www/seowebchecker` to the official FreeBSD ports tree.
