# SEOWebChecker - Bit Composable Components

[![Bit Cloud](https://img.shields.io/badge/Bit.dev-Component-purple.svg)](https://bit.dev/)
[![React](https://img.shields.io/badge/React-Component-61dafb.svg)](https://react.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Reusable, composable Bit components for real-time technical SEO audits, Core Web Vitals indicators, and website health badges powered by [SEOWebChecker](https://seowebchecker.com/).

---

## Components Included

### 1. `seo-audit-badge`
- **Live Preview & Documentation**: Built with MDX specification (`seo-audit-badge.docs.mdx`) and visual compositions (`seo-audit-badge.composition.tsx`).
- **Framework Support**: React 17+, React 18, React 19, Next.js (App & Pages router), Remix, Vite.
- **Features**:
  - Live on-page health score indicator (0–100) with color-coded status badges.
  - Expandable diagnostic details (Title, Meta Description, H1 Structure, Canonical tags, Core Web Vitals).
  - Configurable audit target URL.

---

## Installation via Bit or NPM

### Using Bit CLI
```bash
bit install @seowebchecker/seo-audit.seo-audit-badge
```

### Using standard NPM / PNPM / Yarn
```bash
npm install @seowebchecker/seo-audit-badge
```

---

## Usage in React / Next.js

```tsx
import React from 'react';
import { SeoAuditBadge } from '@seowebchecker/seo-audit.seo-audit-badge';

export default function MyDashboard() {
  return (
    <div>
      <h2>Website Performance & SEO</h2>
      <SeoAuditBadge
        url="https://seowebchecker.com/"
        initialScore={98}
        showDetails={true}
      />
    </div>
  );
}
```

---

## Publishing / Exporting to Bit Cloud (`bit.dev`)

1. Login to Bit Cloud:
   ```bash
   bit login
   ```
2. Tag the component version:
   ```bash
   bit tag --all --message "Initial release of SEOWebChecker SEO Audit badge"
   ```
3. Export to your Bit Cloud scope:
   ```bash
   bit export
   ```
