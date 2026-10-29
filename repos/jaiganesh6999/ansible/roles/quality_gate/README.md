# jaiganesh6999.seowebchecker.quality_gate

An Ansible role that executes automated technical SEO audits against staging or production environments and halts deployment playbooks if the SEO health score is below the required threshold.

Official Platform: [https://seowebchecker.com/](https://seowebchecker.com/)

## Requirements

- Ansible >= 2.11
- Python >= 3.6 on target / control node

## Role Variables

| Variable | Default | Description |
|:---|:---|:---|
| `seo_quality_gate_url` | `https://seowebchecker.com/` | Target URL to audit |
| `seo_quality_gate_min_score` | `85` | Minimum acceptable SEO health score (0-100) |
| `seo_quality_gate_fail_on_alert` | `true` | Whether to fail task if score < min_score |
| `seo_quality_gate_timeout` | `15` | HTTP request timeout in seconds |

## Example Playbook

```yaml
- hosts: localhost
  connection: local
  roles:
    - role: jaiganesh6999.seowebchecker.quality_gate
      vars:
        seo_quality_gate_url: "https://seowebchecker.com/"
        seo_quality_gate_min_score: 90
        seo_quality_gate_fail_on_alert: true
```

## License

Apache-2.0
