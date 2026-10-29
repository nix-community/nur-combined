# SEOWebChecker Postman API Collection 📮

Official Postman API Collection and Environment for [SEOWebChecker](https://seowebchecker.com/) — On-page technical SEO audits, meta tag validation, Open Graph verification, and Core Web Vitals checks.

[![Postman](https://img.shields.io/badge/Postman-Public%20API%20Network-orange?logo=postman)](https://www.postman.com/)
[![Powered by SEOWebChecker](https://img.shields.io/badge/Audits%20by-SEOWebChecker.com-4CAF50.svg)](https://seowebchecker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## ⚡ Direct Import (Web & Desktop)

You can import this collection directly into **Postman Web** or **Postman Desktop**:

### Option A: Import via Raw URL (1-Click)
1. Open **[Postman](https://web.postman.co/)** (Web or Desktop app).
2. Click the **"Import"** button in the top left.
3. Paste this raw URL:
   ```
   https://raw.githubusercontent.com/jaiganesh6999/seowebchecker-seoaudit-sdk/main/postman/seowebchecker.postman_collection.json
   ```
4. Click **Import**.

### Option B: Import Local Files
1. In Postman, click **Import**.
2. Drag and drop:
   - [`seowebchecker.postman_collection.json`](./seowebchecker.postman_collection.json)
   - [`seowebchecker.postman_environment.json`](./seowebchecker.postman_environment.json)

---

## 🌐 Publishing to the Postman Public API Network (DA 92)

To make your collection publicly discoverable by millions of developers on the **Postman Public API Network** (`postman.com/explore`):

1. **Sign in to Postman:**
   Go to [https://www.postman.com/](https://www.postman.com/) and sign in.
2. **Create a Public Workspace:**
   - Click **Workspaces** (top left) → **Create Workspace**.
   - Name: `SEOWebChecker`.
   - Visibility: Select **Public**.
   - Summary: `Official workspace for SEOWebChecker technical SEO and audit APIs.`
3. **Import Collection:**
   - In your new public workspace, import `seowebchecker.postman_collection.json`.
4. **Publish / Share Collection:**
   - Click the **`...`** (more options) next to the imported collection.
   - Select **Share** → **Via Run in Postman button** or **Publish to API Network**.
   - Provide the overview and link to **`https://seowebchecker.com/`**.

---

## 📦 Included Requests

| Request | Method | Path | Has Saved Example? | Description |
| :--- | :---: | :---: | :---: | :--- |
| **1. Quick SEO Health Score** | `GET` | `/api/score` | ✅ Yes (200 OK) | Rapid 0–100 score and letter grade (A+ to F). |
| **2. Full Technical SEO Audit** | `POST` | `/api/audit` | ✅ Yes (200 OK) | Comprehensive 50+ check technical SEO report in JSON. |
| **3. Meta Tags & Social Previews** | `GET` | `/api/meta` | ✅ Yes (200 OK) | Validates title, description, canonical link, mobile viewport, and OpenGraph/Twitter previews. |
| **4. Core Web Vitals Diagnostics** | `GET` | `/api/vitals` | ✅ Yes (200 OK) | Evaluates LCP, CLS, INP, page weight, and TTFB. |
| **5. Image & Alt Text Inspection** | `GET` | `/api/images` | ✅ Yes (200 OK) | Scans `<img>` elements for missing alt tags and modern formats. |

---

## 🎭 Postman Mock Server & Examples

Postman Mock Servers return the **saved examples** configured inside the collection. Each request in this collection includes a realistic `200 OK` example response.

### Mock Server URL
```
https://49d4b282-e139-41f5-b623-41bc064e1c62.mock.pstmn.io
```

### How to Test the Mock Server

#### 1. In Postman App / Web
- Set your active environment to `SEOWebChecker Postman Mock Server` (or set `baseUrl` variable to `https://49d4b282-e139-41f5-b623-41bc064e1c62.mock.pstmn.io/`).
- Send any request (`/api/score`, `/api/meta`, `/api/vitals`, `/api/images`, `/api/audit`).
- Postman Mock Server will immediately match the request to the saved example and return `200 OK`!

#### 2. Using cURL / Terminal
```bash
# Test Health Score
curl "https://49d4b282-e139-41f5-b623-41bc064e1c62.mock.pstmn.io/api/score?url=https://seowebchecker.com/"

# Test Meta Tags
curl "https://49d4b282-e139-41f5-b623-41bc064e1c62.mock.pstmn.io/api/meta?url=https://seowebchecker.com/"

# Test Vitals
curl "https://49d4b282-e139-41f5-b623-41bc064e1c62.mock.pstmn.io/api/vitals?url=https://seowebchecker.com/"

# Test Image Audit
curl "https://49d4b282-e139-41f5-b623-41bc064e1c62.mock.pstmn.io/api/images?url=https://seowebchecker.com/"

# Test Full Audit (POST)
curl -X POST "https://49d4b282-e139-41f5-b623-41bc064e1c62.mock.pstmn.io/api/audit" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://seowebchecker.com/"}'
```

#### 3. How to Update Examples in Postman UI
If you need to edit or add more examples directly in the Postman web/desktop app:
1. In the left sidebar, click any request (e.g. `1. Quick SEO Health Score`).
2. In the top right of the request tab, click the **Examples** dropdown (or click the `...` next to the request name in the sidebar and choose **Add Example**).
3. Set **Status** to `200 OK`, body to `JSON`, paste the desired mock response, and click **Save**.


---

## 📄 License

MIT License. See [LICENSE](../LICENSE) for details.
