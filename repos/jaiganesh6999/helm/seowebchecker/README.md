# SEOWebChecker Kubernetes Helm Chart

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/seowebchecker)](https://artifacthub.io/packages/search?repo=seowebchecker)
[![Version: 1.0.0](https://img.shields.io/badge/Helm%20Chart-1.0.0-informational?style=flat-square)](https://artifacthub.io/)
[![Type: Application](https://img.shields.io/badge/Type-Application-informational?style=flat-square)](https://artifacthub.io/)
[![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)](https://artifacthub.io/)
[![Platform](https://img.shields.io/badge/Platform-seowebchecker.com-indigo)](https://seowebchecker.com/)

Official Kubernetes Helm Chart for **SEOWebChecker** — automated continuous technical SEO auditing, scheduled CronJob watchdogs, cluster-native Prometheus metrics telemetry, and Helm post-deployment regression guards.

Powered by the [SEOWebChecker](https://seowebchecker.com/) technical SEO analysis platform.

---

## ⚡ The 3 Kubernetes Architecture Patterns

This Helm chart implements 3 cloud-native architectural patterns for technical SEO in Kubernetes:

### 1. ⏰ Scheduled Kubernetes CronJob (Continuous SEO Regression Watchdog)
- Deploys a Kubernetes `CronJob` that executes on a schedule (e.g. daily at 2:00 AM: `0 2 * * *`).
- Automatically crawls and audits production and staging URLs for:
  - Title tag presence and length optimization (30–60 characters).
  - Meta description presence and length balance (70–160 characters).
  - Heading structure hierarchy and duplicate `<h1>` tags.
  - Image accessibility (`alt` attribute presence).
  - Mobile viewport readiness and zoom compliance.
  - Canonical link tag integrity.
- Dispatches alert payloads to Slack, Microsoft Teams, or Discord webhooks when SEO scores drop below a defined threshold (`minScore`).

### 2. 📊 Microservice & Prometheus Exporter (Cluster-Native SEO Telemetry)
- Deploys an internal lightweight microservice (`Deployment` + `Service`).
- Exposes an on-demand audit REST API: `GET /audit?url=https://example.com`
- Exposes standard Prometheus `/metrics` endpoint:
  - `seowebchecker_health_score{url="..."}`
- Integrates seamlessly with **Prometheus Operator** (`ServiceMonitor`) and **Grafana** to visualize SEO health metrics alongside cluster CPU, memory, and Core Web Vitals latency.

### 3. 🛡️ Helm Post-Deploy Hook (CI/CD Deployment Guard)
- Executes automatically as a Helm lifecycle hook (`"helm.sh/hook": "post-install,post-upgrade"`).
- Immediately audits newly deployed application ingress routes.
- Automatically fails the release if critical SEO regressions (missing titles, removed viewport tags, duplicate H1s) are detected, enabling automated rollback.

---

## 🚀 Installation & Quick Start

### 1. Add the Helm Repository

```bash
helm repo add seowebchecker https://jaiganesh6999.github.io/seowebchecker-seoaudit-sdk/
helm repo update
```

### 2. Install the Chart

```bash
# Default installation (CronJob watchdog + Prometheus Microservice)
helm install seowebchecker seowebchecker/seowebchecker \
  --set cronjob.targets[0].url="https://seowebchecker.com/" \
  --set cronjob.minScore=85
```

---

## ⚙️ Configuration Parameters

The following table lists the configurable parameters of the SEOWebChecker chart and their default values:

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `cronjob.enabled` | Enable scheduled CronJob SEO watchdog | `true` |
| `cronjob.schedule` | Cron schedule expression | `"0 2 * * *"` (Daily 2 AM UTC) |
| `cronjob.targets` | List of URLs to audit on each cron execution | `[{"url": "https://seowebchecker.com/", "name": "production"}]` |
| `cronjob.minScore` | Minimum acceptable score before triggering alerts | `80` |
| `cronjob.alertWebhook` | Optional Slack/Teams/Discord incoming webhook URL | `""` |
| `server.enabled` | Enable internal REST microservice and metrics | `true` |
| `server.replicaCount` | Microservice replica count | `1` |
| `server.service.type` | Kubernetes service type | `ClusterIP` |
| `server.service.port` | Service port | `8080` |
| `server.metrics.enabled` | Expose Prometheus metrics endpoint at `/metrics` | `true` |
| `server.serviceMonitor.enabled` | Create Prometheus Operator `ServiceMonitor` resource | `false` |
| `postDeployHook.enabled` | Run immediate audit as a Helm post-deploy hook | `false` |
| `postDeployHook.targetUrl` | Ingress URL to audit after deployment | `"https://seowebchecker.com/"` |
| `postDeployHook.failOnRegression` | Abort Helm release if target score < `minScore` | `true` |
| `postDeployHook.minScore` | Minimum acceptable score for post-deploy verification | `85` |
| `podSecurityContext.runAsNonRoot` | Enforce non-root container execution | `true` |

---

## 📊 Prometheus & Grafana Integration

When `server.enabled` is `true`, scrape metrics using standard annotations or the Prometheus Operator:

```yaml
server:
  serviceMonitor:
    enabled: true
    interval: 60s
    labels:
      release: prometheus-stack
```

Sample Prometheus query for Grafana:
```promql
seowebchecker_health_score{url="https://seowebchecker.com/"}
```

---

## 🌐 Official Platform

For continuous site-wide crawling, multi-page audits, and automated Core Web Vitals monitoring:
👉 **[https://seowebchecker.com/](https://seowebchecker.com/)**

---

## 📄 License

MIT License © 2026 [SEOWebChecker](https://seowebchecker.com/).
