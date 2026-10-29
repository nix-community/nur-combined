# SEOWebChecker — Make.com Custom App Integration

[![Platform](https://img.shields.io/badge/Platform-seowebchecker.com-brightgreen)](https://seowebchecker.com/)
[![Make Integration](https://img.shields.io/badge/Make.com-Custom%20App-purple.svg)](https://www.make.com/en/integrations)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Official [Make.com](https://www.make.com/) (formerly Integromat) custom application for **SEOWebChecker**. Connects real-time technical SEO audits, diagnostic issues, and regression alerts directly into automated visual scenarios across thousands of applications (Slack, Google Sheets, Airtable, Notion, Email, Webhooks, etc.).

Powered by [SEOWebChecker](https://seowebchecker.com/).

---

## 📋 Architecture & Review Fixes Summary

This custom app adheres strictly to the Make Apps DX guidelines and addresses all review requirements:
1. **Live Hosted API Integration**: Replaced mockup responses with live HTTP calls against the SEOWebChecker production REST API at `https://seowebchecker.com/api/v1`.
2. **Production Base Configuration**: Configured `baseUrl` to `https://seowebchecker.com/api/v1`, dynamic `Authorization: Bearer {{connection.apiKey}}` and `X-API-Key: {{connection.apiKey}}` headers, and structured error handling for `{{body.message}}` and `{{body.error}}`.
3. **API Key Connection**: Implemented a secure connection component that validates credentials against `GET /audits?limit=1`.
4. **Matched Interface & Dynamic Threshold**: Output bundle matches all fields returned by the live API; `isAlert` and `status` evaluate dynamically against `parameters.alertThreshold`; `timestamp` is parsed with `parseDate`.
5. **Typed Diagnostics (`issues` & `passes`)**: Structured as arrays with nested collection specs (`id`, `category`, `severity`, `title`, `message`, `recommendation`).
6. **Universal Module**: Implemented the required "Make an API call" (`apiCall`) module for arbitrary relative API requests.
7. **Sentence-Case Formatting**: Module labels, groups (`Audits` and `Other`), parameters, and interface fields conform to Make style conventions.

---

## 🛠️ App Specification & Components

### 1. Base Configuration (`base.imljson`)
- **Base URL**: `https://seowebchecker.com/api/v1`
- **Headers**:
  ```json
  {
    "Authorization": "Bearer {{connection.apiKey}}",
    "X-API-Key": "{{connection.apiKey}}",
    "User-Agent": "SEOWebChecker-Make-App/1.0.0 (+https://seowebchecker.com/)"
  }
  ```
- **Error Handling**:
  ```json
  {
    "response": {
      "error": {
        "message": "[{{statusCode}}] {{ifempty(body.message, body.error, 'An unexpected error occurred while communicating with the SEOWebChecker API.')}}"
      }
    }
  }
  ```

---

### 2. Connection (`connections/apiKey`)
- **Name**: `seowebcheckerApiKey`
- **Label**: `SEOWebChecker API key`
- **Type**: `apiKey`
- **Parameters (`parameters.imljson`)**:
  ```json
  [
    {
      "name": "apiKey",
      "type": "text",
      "label": "API key",
      "required": true,
      "help": "Enter your SEOWebChecker API key. You can obtain or generate your key from your SEOWebChecker account at https://seowebchecker.com/."
    }
  ]
  ```
- **Communication (`api.imljson`)**:
  ```json
  {
    "url": "/audits?limit=1",
    "method": "GET",
    "headers": {
      "Authorization": "Bearer {{parameters.apiKey}}",
      "X-API-Key": "{{parameters.apiKey}}",
      "User-Agent": "SEOWebChecker-Make-App/1.0.0 (+https://seowebchecker.com/)"
    },
    "response": {
      "error": {
        "message": "[{{statusCode}}] {{ifempty(body.message, body.error, 'Invalid API key or unauthorized access.')}}"
      }
    }
  }
  ```

---

### 3. Module: `Run a technical SEO audit`
- **Name**: `seoaudit` (or `runAudit`)
- **Label**: `Run a technical SEO audit`
- **Type**: `Action`
- **Group**: `Audits`
- **Description**: `Performs a real-time technical SEO audit for a target webpage URL, returning health scores, diagnostic issues, and threshold alerts.`

#### Parameters (`expect.imljson`)
```json
[
  {
    "name": "url",
    "type": "url",
    "label": "Webpage URL",
    "required": true,
    "help": "Enter the full webpage URL to audit (e.g. https://example.com/)."
  },
  {
    "name": "alertThreshold",
    "type": "uinteger",
    "label": "Alert score threshold",
    "required": false,
    "default": 85,
    "min": 0,
    "max": 100,
    "help": "Trigger an alert flag if the technical SEO score drops below this number (0-100)."
  }
]
```

#### API Communication (`api.imljson`)
```json
{
  "url": "/audit",
  "method": "POST",
  "body": {
    "url": "{{parameters.url}}"
  },
  "response": {
    "output": {
      "id": "{{body.id}}",
      "targetUrl": "{{body.url}}",
      "score": "{{ifempty(body.score.overall, body.score)}}",
      "grade": "{{ifempty(body.score.grade, body.grade)}}",
      "status": "{{if(ifempty(body.score.overall, body.score) < parameters.alertThreshold; 'ALERT'; 'PASS')}}",
      "isAlert": "{{ifempty(body.score.overall, body.score) < parameters.alertThreshold}}",
      "title": "{{body.title}}",
      "metaDescription": "{{body.metaDescription}}",
      "issuesCount": "{{ifempty(body.stats.errors + body.stats.warnings, length(body.issues))}}",
      "issues": "{{body.issues}}",
      "passesCount": "{{ifempty(body.stats.passed, length(body.passes))}}",
      "passes": "{{body.passes}}",
      "auditedAt": "{{parseDate(body.timestamp; 'YYYY-MM-DDTHH:mm:ss.SSSZ')}}",
      "platformUrl": "https://seowebchecker.com/"
    }
  }
}
```

#### Interface (`interface.imljson`)
See [`modules/seoaudit/interface.imljson`](modules/seoaudit/interface.imljson) for the full 14-field specification including typed array collections for `issues` and `passes`.

---

### 4. Module: `Make an API call` (Universal Module)
- **Name**: `apiCall`
- **Label**: `Make an API call`
- **Type**: `rest`
- **Group**: `Other`
- **Description**: `Performs an arbitrary authorized API call to the SEOWebChecker API.`

#### Parameters (`expect.imljson`)
- `url` (Text, Required): Relative endpoint path (e.g. `/audit`, `/audits`).
- `method` (Select, Required): `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `HEAD`.
- `headers` (Collection, Optional): Additional HTTP request headers.
- `qs` (Collection, Optional): Query string parameters.
- `body` (Any, Optional): Request payload body.

---

## 📡 Hosted API Reference Documentation

- **Base URL**: `https://seowebchecker.com/api/v1`
- **Authentication**: Bearer Token or Header key:
  - `Authorization: Bearer <API_KEY>`
  - `X-API-Key: <API_KEY>`
- **Endpoints**:
  - `POST /audit`: Execute an audit on a target webpage (`{"url": "https://example.com/"}`).
  - `GET /audit/:id`: Retrieve single audit results by audit ID.
  - `GET /audits?limit=10`: Retrieve historical audit records.
- **Error Response Format**:
  ```json
  {
    "statusCode": 400,
    "error": "Bad Request",
    "message": "Invalid webpage URL provided or target unreachable."
  }
  ```

---

## 🧪 Testing Scenarios for Make Reviewers

To verify approval in Make Developer Console:
1. **Scenario 1 — Successful Audit**:
   - Add module **Run a technical SEO audit**.
   - Input: URL = `https://seowebchecker.com/`, Alert score threshold = `85`.
   - Run Once: Verify score (e.g. 96), grade (`A+`), status (`PASS`), `isAlert: false`, populated `passes` array, and parsed ISO `auditedAt`.
2. **Scenario 2 — Threshold Alert Test**:
   - Input: URL = `https://seowebchecker.com/`, Alert score threshold = `99`.
   - Run Once: Verify `status` switches to `ALERT` and `isAlert: true`.
3. **Scenario 3 — Error Test**:
   - Provide an invalid URL (e.g. `invalid://not-a-domain`).
   - Run Once: Verify scenario halts with `[400] Invalid webpage URL provided`.
4. **Scenario 4 — Universal Module**:
   - Add module **Make an API call**.
   - Input: URL = `/audits?limit=1`, Method = `GET`.
   - Run Once: Verify `statusCode: 200` with headers and body bundle.

---

## 📄 License

MIT License. Engineered by the [SEOWebChecker](https://seowebchecker.com/) team.
