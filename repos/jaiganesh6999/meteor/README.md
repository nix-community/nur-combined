# SEOWebChecker Meteor Package ☄️

Official Meteor package for automated on-page technical SEO audits, meta tag validation, Open Graph verification, and Core Web Vitals checks.

- **Official Web Suite:** [https://seowebchecker.com/](https://seowebchecker.com/)
- **Atmosphere Registry:** [https://atmospherejs.com/](https://atmospherejs.com/)
- **Documentation:** [https://seo-ai-tools.readthedocs.io/en/latest/](https://seo-ai-tools.readthedocs.io/en/latest/)

---

## ⚡ Installation

Install directly into your Meteor application using Atmosphere:

```bash
meteor add seowebchecker:seoaudit-sdk
```

---

## 🛠️ Usage

### Server-side or Client-side Audit

```javascript
import { SEOAuditor } from 'meteor/seowebchecker:seoaudit-sdk';

const auditor = new SEOAuditor();

// Run audit on any URL
const result = await auditor.audit('https://seowebchecker.com/');

console.log(`Overall Score: ${result.score}/100 (Grade: ${result.grade})`);
console.log(`Title: ${result.meta.title}`);
console.log(`Canonical: ${result.meta.canonical}`);
```

### Meteor Server Method

```javascript
import { Meteor } from 'meteor/meteor';
import { SEOAuditor } from 'meteor/seowebchecker:seoaudit-sdk';

Meteor.methods({
  async 'seo.auditUrl'(url) {
    const auditor = new SEOAuditor();
    return await auditor.audit(url);
  }
});
```

---

## 📄 Publishing to Atmosphere

From within this `meteor/` directory:

```bash
# 1. Login with your Meteor Developer account
meteor login

# 2. Publish directly to Atmosphere
meteor publish --create
```

*No GitHub Pull Request or third-party review needed — your package goes live on Atmosphere instantly!*

---

## 📄 License

MIT License. See [LICENSE](../LICENSE) for details.
