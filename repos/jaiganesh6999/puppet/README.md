# jaiganesh6999-seowebchecker

[![Puppet Forge](https://img.shields.io/puppetforge/v/jaiganesh6999/seowebchecker.svg)](https://forge.puppet.com/modules/jaiganesh6999/seowebchecker)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/jaiganesh6999/seowebchecker.svg)](https://forge.puppet.com/modules/jaiganesh6999/seowebchecker)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-https%3A%2F%2Fseowebchecker.com%2F-brightgreen)](https://seowebchecker.com/)

A production-grade Puppet module and Puppet Bolt task suite for automated technical SEO monitoring, quality gate enforcement, and health reporting powered by [SEOWebChecker](https://seowebchecker.com/).

---

## Overview

Modern infrastructure deployments require that production and staging websites adhere to strict on-page technical SEO standards. **jaiganesh6999-seowebchecker** enables DevOps and infrastructure engineers to:

- 🤖 **Automate Audits on Web Nodes**: Schedule continuous SEO health checks directly across Apache, Nginx, or Kubernetes edge nodes.
- 🚦 **Enforce Quality Gate Thresholds**: Ensure deployments satisfy minimum SEO score requirements (e.g. `score >= 85`) before traffic is served.
- ⚡ **Puppet Bolt Ad-hoc Audits**: Run instant cross-platform audits on Linux and Windows targets via `puppet task run`.
- 📊 **Export Reports**: Generate machine-readable JSON logs and web-accessible reports for CI/CD dashboards.

---

## Installation

Install via the Puppet CLI from [Puppet Forge](https://forge.puppet.com/modules/jaiganesh6999/seowebchecker):

```bash
puppet module install jaiganesh6999-seowebchecker
```

Or add to your `Puppetfile`:

```ruby
mod 'jaiganesh6999-seowebchecker', '1.0.0'
```

---

## Usage

### 1. Basic Setup

Include the module in your node classification:

```puppet
include seowebchecker
```

### 2. Monitoring Virtual Hosts & Web Endpoints

Configure scheduled audits for your web services:

```puppet
class { 'seowebchecker':
  default_alert_threshold => 85,
  report_dir              => '/var/www/html/seo-reports',
  sites                   => {
    'primary_domain' => {
      'url'             => 'https://seowebchecker.com/',
      'alert_threshold' => 90,
      'cron_schedule'   => 'daily',
    },
    'staging_environment' => {
      'url'             => 'https://staging.example.com/',
      'alert_threshold' => 85,
      'cron_schedule'   => 'hourly',
    },
  },
}
```

Or declare sites independently using the defined resource type:

```puppet
seowebchecker::site { 'https://seowebchecker.com/':
  alert_threshold => 90,
  cron_schedule   => 'daily',
}
```

---

## Puppet Bolt Tasks

Run instant ad-hoc audits against any web target without modifying node state:

```bash
# Run task against remote Linux or Windows targets
bolt task run seowebchecker::audit url=https://seowebchecker.com/ threshold=90 --targets web-servers
```

### Example Task JSON Output:
```json
{
  "url": "https://seowebchecker.com/",
  "score": 100,
  "grade": "A+",
  "status": "PASS",
  "title": "SEOWebChecker — Technical SEO Audit & Analyzer",
  "title_length": 47,
  "has_viewport": true,
  "has_canonical": true,
  "canonical_url": "https://seowebchecker.com/",
  "is_https": true,
  "h1_count": 1,
  "word_count": 480,
  "response_time_ms": 115,
  "issues_count": 0,
  "passes_count": 7,
  "platform_url": "https://seowebchecker.com/",
  "timestamp": "2026-10-23T16:00:00Z"
}
```

---

## Audit Dimensions

| Area | Checks | Criteria |
|:---|:---|:---|
| **Meta** | Title Tag | 30–65 characters, descriptive intent |
| **Meta** | Meta Description | 70–160 characters |
| **Technical** | Mobile Viewport | Responsive `<meta name="viewport">` declaration |
| **Technical** | Canonical URL | Valid self-referencing canonical tag |
| **Technical** | HTTPS Security | Secure encrypted protocol active |
| **Content** | Heading Hierarchy | Exactly 1 primary `<h1>` heading |
| **Content** | Word Count | ≥ 100 words of indexable copy |

---

## Reference & Documentation

- **Official Platform**: [https://seowebchecker.com/](https://seowebchecker.com/)
- **Puppet Forge Listing**: [https://forge.puppet.com/modules/jaiganesh6999/seowebchecker](https://forge.puppet.com/modules/jaiganesh6999/seowebchecker)
- **Source Code**: [https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk)

---

## License

Apache-2.0 License. See [LICENSE](LICENSE) for details.
