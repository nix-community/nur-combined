# vite-plugin-seowebchecker

[![npm version](https://img.shields.io/npm/v/vite-plugin-seowebchecker.svg)](https://www.npmjs.com/package/vite-plugin-seowebchecker)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Official Site](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)

A lightweight [Vite](https://vite.dev/) plugin for automated on-page technical SEO audits, meta tag validations, heading structure inspections, image accessibility checks, and Core Web Vitals diagnostics. Powered by **[SEOWebChecker.com](https://seowebchecker.com/)**.

---

## ⚡ Features

- **Automated Build Audits**: Automatically analyzes all output HTML files generated during `vite build`.
- **Zero Configuration Needed**: Works out-of-the-box with sensible production defaults.
- **CI/CD Quality Gate**: Optionally fail builds (`failOnError: true` or `minScore: 90`) if critical SEO regressions occur.
- **Detailed Terminal Reporting**: Clean, formatted console summaries during build time.
- **Fast & Dependency-Free**: Ultra-fast regex-based parsing without heavy DOM dependencies.

---

## 📦 Installation

```bash
# npm
npm install --save-dev vite-plugin-seowebchecker

# yarn
yarn add -D vite-plugin-seowebchecker

# pnpm
pnpm add -D vite-plugin-seowebchecker
```

---

## 🚀 Usage

Add `seoWebCheckerPlugin` to your `vite.config.js` or `vite.config.ts`:

```javascript
// vite.config.js
import { defineConfig } from 'vite';
import seoWebChecker from 'vite-plugin-seowebchecker';

export default defineConfig({
  plugins: [
    seoWebChecker({
      failOnError: false, // Set to true to fail CI builds on SEO errors
      minScore: 80,       // Minimum acceptable SEO score (0-100)
      verbose: true,      // Log findings in terminal during build
    }),
  ],
});
```

---

## ⚙️ Configuration Options

| Option | Type | Default | Description |
| :--- | :--- | :---: | :--- |
| `failOnError` | `boolean` | `false` | If `true`, aborts the build process when critical SEO errors are detected. |
| `minScore` | `number` | `0` | Minimum score (0-100) required to pass the build. |
| `verbose` | `boolean` | `true` | Print detailed audit reports in the terminal. |
| `ignorePaths` | `Array<string\|RegExp>` | `[]` | List of HTML file paths to skip from auditing. |

---

## 📄 License

MIT © [SEOWebChecker](https://seowebchecker.com/)
