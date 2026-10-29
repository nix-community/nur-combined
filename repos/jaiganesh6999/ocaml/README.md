# SEOWebChecker - OCaml SDK & CLI

[![Platform](https://img.shields.io/badge/Platform-seowebchecker.com-brightgreen)](https://seowebchecker.com/)
[![OPAM](https://img.shields.io/badge/OPAM-Package-orange.svg)](https://opam.ocaml.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Official [OCaml](https://ocaml.org/) SDK and CLI tool for **SEOWebChecker**. Brings typed on-page technical SEO diagnostics, heading structure validation, Core Web Vitals checks, accessibility auditing, and automated regression alerts to the OCaml ecosystem.

Powered by the [SEOWebChecker](https://seowebchecker.com/) platform.

---

## ℹ️ Important Note: `forge.ocamlcore.org` vs `opam.ocaml.org`

* **`forge.ocamlcore.org` (OCamlForge)**: Was an older community hosting forge from the early OCaml days. It has been **retired/archived** by the OCaml community.
* **`opam.ocaml.org` (OPAM Repository)**: The modern, official central package manager and registry for all OCaml packages worldwide. **This is the current platform to publish to.**

---

## ⚡ Features

* **Complete Technical SEO Auditing**:
  * Title tag presence and length optimization (30–60 characters).
  * Meta description presence and length checks (70–160 characters).
  * Heading hierarchy validation (ensuring exactly one `<h1>` tag and flagging duplicate H1s).
  * Mobile viewport meta tag verification.
  * Canonical link tag validation.
  * Image accessibility (`<img>` `alt` attributes).
  * OpenGraph social sharing preview tags (`og:title`, `og:image`).
* **Typed OCaml Data Structures**:
  * Clean algebraic data types for grades (`A`, `B`, `C`, `D`, `F`), statuses (`Pass`, `Alert`), and audit results.
  * Seamless serialization to JSON via `yojson`.
* **Async HTTP Engine**:
  * Non-blocking HTTP crawling powered by `cohttp-lwt-unix` and `lambdasoup`.

---

## 🛠️ Building & Testing Locally

Requirements: OCaml >= 4.12 and Dune >= 3.0.

```bash
cd ocaml

# Build library and CLI executable
dune build

# Run unit tests
dune runtest

# Run CLI audit
_build/default/bin/main.exe https://seowebchecker.com/
```

---

## 🚀 How to Publish to `opam.ocaml.org`

Publishing to OPAM is managed through the central repository: [ocaml/opam-repository](https://github.com/ocaml/opam-repository).

### Method 1: Automated Release via `dune-release` (Recommended)

1. **Tag the release in git**:
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```

2. **Publish archive to GitHub releases**:
   ```bash
   dune-release distrib
   dune-release publish distrib
   ```

3. **Submit to the OPAM Repository**:
   ```bash
   dune-release opam submit
   ```
   *(`dune-release` automatically opens a Pull Request to `ocaml/opam-repository` with the tarball checksum and metadata).*

---

### Method 2: Manual Pull Request to `ocaml/opam-repository`

1. Fork **[https://github.com/ocaml/opam-repository](https://github.com/ocaml/opam-repository)**.
2. In your fork, create a new directory:
   ```text
   packages/seowebchecker/seowebchecker.1.0.0/
   ```
3. Copy `seowebchecker.opam` into that directory named `opam`.
4. Append the release tarball URL and SHA checksum at the end of the `opam` file:
   ```opam
   url {
     src: "https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/archive/refs/tags/v1.0.0.tar.gz"
     checksum: "sha256=<ARCHIVE_SHA256_HASH>"
   }
   ```
5. Open a Pull Request to `ocaml/opam-repository`.
6. Once merged, developers can install it globally via:
   ```bash
   opam update
   opam install seowebchecker
   ```

---

## 📄 License

MIT License. Engineered by the [SEOWebChecker](https://seowebchecker.com/) team.
