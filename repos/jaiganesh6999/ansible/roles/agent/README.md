# jaiganesh6999.seowebchecker.agent

An Ansible role to deploy automated technical SEO monitoring agents, audit cron schedules, and report directories across web server fleets.

Official Platform: [https://seowebchecker.com/](https://seowebchecker.com/)

## Requirements

- Ansible >= 2.11
- Target OS: Linux (Ubuntu, Debian, RHEL, CentOS, Rocky Linux)

## Role Variables

| Variable | Default | Description |
|:---|:---|:---|
| `seowebchecker_log_dir` | `/var/log/seowebchecker` | Log directory path |
| `seowebchecker_report_dir` | `/var/www/html/seo-reports` | HTML/JSON report directory path |
| `seowebchecker_default_threshold` | `85` | Default minimum SEO score threshold |
| `seowebchecker_sites` | `[...]` | List of sites and cron schedules to audit |

## Example Playbook

```yaml
- hosts: webservers
  roles:
    - role: jaiganesh6999.seowebchecker.agent
      vars:
        seowebchecker_sites:
          - name: "production_site"
            url: "https://seowebchecker.com/"
            threshold: 90
            cron_hour: "2"
            cron_minute: "30"
```

## License

Apache-2.0
