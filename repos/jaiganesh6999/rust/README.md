# seowebchecker-seoaudit-sdk (Rust / Crates.io)

[![Crates.io](https://img.shields.io/crates/v/seowebchecker-seoaudit-sdk.svg)](https://crates.io/crates/seowebchecker-seoaudit-sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Official Site](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)

High-performance, lightweight Rust client SDK and CLI tool for full website SEO audits and on-page optimization diagnostics.

Official website: **[https://seowebchecker.com/](https://seowebchecker.com/)**

## Installation

Add to your `Cargo.toml`:

```toml
[dependencies]
seowebchecker-seoaudit-sdk = "1.0.0"
```

## Quick Start (Rust)

```rust
use seowebchecker_seoaudit::SEOAuditor;

fn main() {
    let auditor = SEOAuditor::new();
    let html = "<html><head><title>My Site</title></head><body><h1>Welcome</h1></body></html>";
    let result = auditor.audit_html(html, "https://example.com");

    println!("Score: {}/100 (Grade: {})", result.score.overall, result.score.grade);
    println!("Passed: {}, Errors: {}", result.passed_checks, result.errors);
}
```

## CLI Tool

Install via cargo:

```bash
cargo install seowebchecker-seoaudit-sdk
seowebchecker-audit https://example.com
```

## License

MIT License © 2026 [SEOWebChecker](https://seowebchecker.com/).
