# seowebchecker-seoaudit-sdk (Ruby)

[![Gem Version](https://badge.fury.io/rb/seowebchecker-seoaudit-sdk.svg)](https://rubygems.org/gems/seowebchecker-seoaudit-sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Official Site](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)

Lightweight open-source Ruby client SDK and CLI tool for full website SEO audits, on-page analysis, and technical diagnostics.

Official website: **[https://seowebchecker.com/](https://seowebchecker.com/)**

## Installation

Add to your `Gemfile`:

```ruby
gem 'seowebchecker-seoaudit-sdk'
```

Or install via `gem`:

```bash
gem install seowebchecker-seoaudit-sdk
```

## Quick Start

```ruby
require 'seowebchecker_seoaudit'

auditor = SeoWebChecker::SeoAudit::Auditor.new
result = auditor.audit('https://example.com')

puts "Score: #{result[:score][:overall]}/100 (Grade: #{result[:score][:grade]})"
puts "Passed: #{result[:stats][:passed]}, Warnings: #{result[:stats][:warnings]}, Errors: #{result[:stats][:errors]}"
```

## CLI Usage

```bash
seowebchecker-audit https://example.com --format json
seowebchecker-audit https://example.com --min-score 85
```

## License

MIT License © 2026 [SEOWebChecker](https://seowebchecker.com/).
