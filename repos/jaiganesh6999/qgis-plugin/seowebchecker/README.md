# SEOWebChecker GeoSEO — QGIS Plugin

[![QGIS Plugin](https://img.shields.io/badge/QGIS-Plugin-589632.svg?logo=qgis&logoColor=white)](https://plugins.qgis.org/)
[![License: GPL v2+](https://img.shields.io/badge/License-GPL%20v2%2B-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-https%3A%2F%2Fseowebchecker.com%2F-brightgreen)](https://seowebchecker.com/)

A geospatial local SEO and technical web auditing plugin for **QGIS (Quantum GIS)**, powered by [SEOWebChecker](https://seowebchecker.com/).

Connects Geographic Information Systems (GIS) with on-page technical SEO, mobile viewport readiness, canonical URL validation, and Schema.org `GeoCoordinates` spatial intelligence.

---

## Key Features

- 📍 **Schema.org GeoCoordinates Extraction**: Automatically detects and parses `latitude`, `longitude`, `PostalAddress`, and `LocalBusiness` data from structured JSON-LD and microdata.
- 🗺️ **One-Click Spatial Layer Creation**: Add audited web properties directly as vector point features onto your QGIS map canvas.
- ⚡ **Batch Layer GeoSEO Enrichment**: Select any existing vector layer (retail stores, franchise branches, client directories) containing website URLs, perform automated audits, and enrich the attribute table with `SEO_Score`, `SEO_Grade`, and `SEO_Status`.
- 🚦 **Technical SEO Diagnostic Suite**: Evaluates title tag, meta description, mobile viewport configuration, canonical URL consistency, heading hierarchies, indexable word volume, and HTTPS encryption.
- 🎨 **Visual Score Symbology**: Color-code map points according to SEO health scores (Green for A+ ≥ 90, Yellow for B 80–89, Red for < 80 Alert).

---

## Installation in QGIS

### Option 1: Via Official QGIS Plugin Repository
1. In QGIS, navigate to **Plugins** > **Manage and Install Plugins...**
2. Search for **SEOWebChecker GeoSEO**.
3. Click **Install Plugin**.

### Option 2: Manual Installation from ZIP
1. Download `seowebchecker.zip`.
2. In QGIS, open **Plugins** > **Manage and Install Plugins...** > **Install from ZIP**.
3. Select `seowebchecker.zip` and click **Install Plugin**.

---

## Usage Guide

### 1. Single URL Audit & Map Pinning
1. Click the **SEOWebChecker GeoSEO** icon in the QGIS Web Toolbar or navigate to **Plugins** > **Web** > **SEOWebChecker**.
2. Enter the target URL (e.g. `https://seowebchecker.com/`).
3. Click **Run SEO Audit**.
4. Review the health score (0–100), academic grade, issues, and extracted geographic coordinates.
5. Click **📍 Add Spatial Point to QGIS Map** to pin the location as a vector feature.

### 2. Batch Layer Audit & Table Enrichment
1. Switch to the **Batch Layer Audit** tab.
2. Select your active vector layer (e.g., `store_locations`).
3. Select the attribute field containing website URLs.
4. Set your minimum passing alert threshold (default: 85).
5. Click **⚡ Audit Layer Features & Enrich Table**.
6. The plugin dynamically adds `SEO_Score`, `SEO_Grade`, and `SEO_Status` columns to your layer's attribute table.

---

## Technical Audit Dimensions

| Category | Check | Evaluation Criteria |
|:---|:---|:---|
| **Meta** | Title Tag | 30–65 characters, descriptive |
| **Meta** | Meta Description | 70–160 characters |
| **Spatial** | GeoCoordinates | Schema.org JSON-LD `latitude` & `longitude` |
| **Technical** | Mobile Viewport | Responsive `<meta name="viewport">` |
| **Technical** | Canonical URL | Valid self-referencing canonical tag |
| **Technical** | HTTPS Security | Secure encrypted protocol active |
| **Content** | Heading Hierarchy | Exactly 1 primary `<h1>` heading |
| **Content** | Word Count | ≥ 100 words of indexable copy |

---

## Official Platform

For deep website crawling, multi-page indexing audits, and API access:
- **Official Site**: [https://seowebchecker.com/](https://seowebchecker.com/)

---

## License

GNU General Public License v2.0 or later. See [LICENSE](LICENSE) for details.
