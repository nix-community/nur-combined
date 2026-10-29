# SEOWebChecker 3D Web Optimizer & SEO Auditor

[![Blender Extensions](https://img.shields.io/badge/Blender-Extension%204.2%2B-orange.svg?logo=blender&logoColor=white)](https://extensions.blender.org/)
[![License: GPL v3+](https://img.shields.io/badge/License-GPL%20v3%2B-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-https%3A%2F%2Fseowebchecker.com%2F-brightgreen)](https://seowebchecker.com/)

A specialized Blender extension designed for 3D web artists, WebGL developers, and digital marketers to optimize 3D assets for **Web3D search visibility**, **Google 3D Search**, and **Core Web Vitals** performance. Powered by [SEOWebChecker](https://seowebchecker.com/).

---

## Why Web3D SEO Matters

Modern search engines (Google, Bing) increasingly index interactive 3D content, augmented reality (AR) quick-look models, and e-commerce product viewers. However, unoptimized 3D models can severely hurt search ranking due to:

1. **Slow Core Web Vitals (CWV / LCP)**: Heavy polygon counts and uncompressed 4K textures delay page rendering.
2. **Missing Search Engine Indexing (JSON-LD)**: Without Schema.org `3DModel` structured data, search engines cannot display rich 3D badges and AR previews in search result snippets.
3. **Improper Mobile Viewport & Draw Calls**: Excess material slots degrade WebGL frame rates on mobile devices.

**SEOWebChecker 3D** solves these challenges directly inside Blender before exporting to glTF 2.0, GLB, or USDZ.

---

## Key Features

- 🔍 **Mesh Web Performance & SEO Audit**:
  - Automatically analyzes active meshes against mobile Web3D and Google 3D search budgets.
  - Inspects triangle count (< 100k target, < 50k optimal), vertex volume, material slots (draw calls), UV mapping, and uniform transform scale.
  - Flags oversized textures (> 2048px) that cause mobile WebGL memory bottlenecks.
  - Delivers a 0–100 Web SEO Health Score and letter grade (A+ through F).

- 🏷️ **Schema.org 3DModel & Product Structured Data Generator**:
  - Generates rich, search-engine-ready JSON-LD structured data for Google 3D search.
  - Supports model URLs (`.glb`, `.gltf`, `.usdz`), descriptions, SKU, brand, and retail offers.
  - One-click copy directly to your clipboard for instant embedding into web pages or CMS templates.

- 🌐 **Live Web Page 3D & Technical SEO Audit**:
  - Directly tests live web pages hosting your 3D models.
  - Verifies presence of `<model-viewer>`, WebGL `<canvas>`, viewport meta tags, title length, meta description, canonical URLs, and server response latency.

---

## Installation

### Method 1: From Blender Extensions Platform (Blender 4.2+)
1. In Blender, navigate to **Edit** > **Preferences** > **Get Extensions**.
2. Search for **SEOWebChecker 3D**.
3. Click **Install**.

### Method 2: Manual Installation from ZIP
1. Download `seowebchecker_3d-1.0.0.zip`.
2. Open Blender, go to **Edit** > **Preferences** > **Extensions**.
3. Click the dropdown menu in the upper-right corner and choose **Install from Disk...**
4. Select `seowebchecker_3d-1.0.0.zip` and activate.

---

## Quick Start Guide

### 1. Auditing a 3D Mesh
1. Open your 3D scene in Blender.
2. Select the target mesh in the 3D Viewport.
3. Press **N** to open the Sidebar and switch to the **SEOWebChecker** tab.
4. Set your desired triangle threshold (default: 100,000).
5. Click **Audit 3D Mesh for Web SEO**.
6. Review your health score, grade, and actionable recommendations.

### 2. Generating Schema.org 3DModel JSON-LD
1. Expand the **Schema.org 3DModel Generator** sub-panel.
2. Enter the Model Name, hosted GLB URL, and optional product details (SKU, brand, price).
3. Click **Generate 3D Schema JSON-LD**.
4. The complete `<script type="application/ld+json">` snippet is copied to your clipboard.

### 3. Auditing a Live Hosting Web Page
1. Expand the **Live Web Page 3D Audit** sub-panel.
2. Enter your live webpage URL (e.g. `https://seowebchecker.com/`).
3. Click **Audit Live Web Page** to evaluate 3D viewer integration and technical SEO health.

---

## Permissions Declared in `blender_manifest.toml`

Blender 4.2+ requires explicit declaration of permissions:

- `network`: Used strictly to audit live web pages hosting 3D models upon user request. Respects `bpy.app.online_access`.
- `clipboard`: Used to copy generated Schema.org JSON-LD snippets to your system clipboard.
- `files`: Used to export Web3D SEO audit reports to disk.

---

## Official Links

- **Platform**: [https://seowebchecker.com/](https://seowebchecker.com/)
- **Repository**: [https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk)
- **Issue Tracker**: [https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/issues](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/issues)

---

## License

GNU General Public License v3.0 or later (SPDX: GPL-3.0-or-later).
