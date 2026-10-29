# Changelog

All notable changes to the `jaiganesh6999-seowebchecker` module are documented here.

## Release 1.0.0

### Features
- Initial release of `jaiganesh6999-seowebchecker` on [Puppet Forge](https://forge.puppet.com/).
- Deploys the automated technical SEO auditing CLI agent on Linux nodes.
- Defined resource type `seowebchecker::site` for managing cron-scheduled web audits.
- Puppet Bolt task `seowebchecker::audit` supporting Linux (Bash) and Windows (PowerShell) nodes.
- Health score evaluation (0-100), academic grade calculation, and alert thresholds.
- Official platform integration with [https://seowebchecker.com/](https://seowebchecker.com/).
