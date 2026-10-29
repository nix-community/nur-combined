# jaiganesh6999.seowebchecker Ansible Collection

[![Ansible Galaxy](https://img.shields.io/badge/Ansible%20Galaxy-jaiganesh6999.seowebchecker-blue.svg)](https://galaxy.ansible.com/ui/repo/published/jaiganesh6999/seowebchecker/)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-https%3A%2F%2Fseowebchecker.com%2F-brightgreen)](https://seowebchecker.com/)

A production-grade Ansible Collection for automated technical SEO audits, deployment quality gate enforcement, and health monitoring, powered by [SEOWebChecker](https://seowebchecker.com/).

---

## Overview

Modern web deployments require continuous validation that on-page SEO elements, mobile responsiveness, and security protocols are not broken during updates.

The **`jaiganesh6999.seowebchecker`** collection provides:

- 🔍 **`jaiganesh6999.seowebchecker.seo_audit`**: Native Ansible action module that audits any live URL or staging endpoint directly within your playbooks.
- 🚦 **Quality Gate Enforcement**: Fails deployment playbooks if a release drops below your target SEO score (e.g. `min_score: 85`).
- 🤖 **`roles/agent`**: Automatically provisions scheduled audit cron jobs and report directories across your web server fleet.
- 🛡️ **`roles/quality_gate`**: Reusable quality gate role for pre-traffic cutover verification.
- ⚡ **Zero External Dependencies**: Pure Python standard library implementation with zero external pip dependencies required on target nodes.

---

## Installation

Install via the `ansible-galaxy` CLI:

```bash
ansible-galaxy collection install jaiganesh6999.seowebchecker
```

Or declare it in your `requirements.yml`:

```yaml
---
collections:
  - name: jaiganesh6999.seowebchecker
    version: ">=1.0.0"
```

Then run:

```bash
ansible-galaxy collection install -r requirements.yml
```

---

## Module Usage: `seo_audit`

### Example 1: Enforcing an SEO Health Quality Gate in Deployment
```yaml
- name: Verify SEO health prior to production traffic switch
  hosts: localhost
  connection: local
  tasks:
    - name: Audit staging URL
      jaiganesh6999.seowebchecker.seo_audit:
        url: "https://seowebchecker.com/"
        min_score: 90
        fail_on_alert: true
      register: audit_result

    - name: Log audit score
      ansible.builtin.debug:
        msg: "SEO Health Score is {{ audit_result.score }}/100 ({{ audit_result.grade }})"
```

### Example 2: Non-failing Diagnostic Audit
```yaml
- name: Audit client endpoints for monitoring
  hosts: localhost
  tasks:
    - name: Audit website
      jaiganesh6999.seowebchecker.seo_audit:
        url: "https://seowebchecker.com/"
        min_score: 80
        fail_on_alert: false
      register: audit_info

    - name: Show detected issues
      ansible.builtin.debug:
        var: audit_info.issues
```

---

## Module Parameters

| Parameter | Type | Default | Description |
|:---|:---|:---|:---|
| `url` | `str` | *(Required)* | Target URL to audit (e.g. `https://seowebchecker.com/`). |
| `min_score` | `int` | `85` | Minimum passing score (0–100) before triggering an alert. |
| `fail_on_alert` | `bool` | `true` | If `true`, fails the Ansible task if `score < min_score`. |
| `timeout` | `int` | `15` | Request timeout in seconds. |
| `user_agent` | `str` | `SEOWebChecker-Ansible/...` | Custom User-Agent header. |

---

## Audit Evaluation Criteria

| Category | Check | Pass Criteria |
|:---|:---|:---|
| **Meta** | Title Tag | Present, 30–65 characters |
| **Meta** | Meta Description | Present, 70–160 characters |
| **Technical** | Mobile Viewport | Responsive `<meta name="viewport">` configured |
| **Technical** | Canonical URL | Valid `<link rel="canonical">` declared |
| **Technical** | HTTPS Security | Secure encrypted protocol active |
| **Content** | Heading Hierarchy | Exactly 1 primary `<h1>` heading |
| **Content** | Word Count | ≥ 100 words of indexable copy |

---

## Roles Included

### 1. `jaiganesh6999.seowebchecker.agent`
Configures cron jobs and reporting paths on web hosts for periodic SEO monitoring:

```yaml
- hosts: webservers
  roles:
    - role: jaiganesh6999.seowebchecker.agent
      vars:
        seowebchecker_sites:
          - name: "corporate_site"
            url: "https://seowebchecker.com/"
            threshold: 90
            cron_hour: "2"
            cron_minute: "0"
```

### 2. `jaiganesh6999.seowebchecker.quality_gate`
Reusable pre-deployment verification gate:

```yaml
- hosts: localhost
  roles:
    - role: jaiganesh6999.seowebchecker.quality_gate
      vars:
        seo_quality_gate_url: "https://seowebchecker.com/"
        seo_quality_gate_min_score: 90
```

---

## Official Platform Reference

For comprehensive web crawling, API keys, and dashboard analytics:
- **Official Site**: [https://seowebchecker.com/](https://seowebchecker.com/)

---

## License

Apache-2.0 License. See [LICENSE](LICENSE) for details.
