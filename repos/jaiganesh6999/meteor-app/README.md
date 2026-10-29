# Deploying SEOWebChecker to Galaxy Cloud 🚀

Complete deployment guide for running the SEOWebChecker Meteor Service & REST API on **Meteor Galaxy Cloud** ([`my.galaxycloud.app`](https://my.galaxycloud.app/)).

Canonical Homepage: [https://seowebchecker.com/](https://seowebchecker.com/)

---

## 📋 Prerequisites
1. A **Meteor Cloud / Galaxy** account at [https://cloud.meteor.com/](https://cloud.meteor.com/).
2. Your repository on GitHub: `jaiganesh6999/seowebchecker-seoaudit-sdk`.

---

## 🛠️ Step-by-Step Deployment via Galaxy Cloud Web UI

### Step 1: Open the Galaxy Deploy Page
Navigate directly to your deploy dashboard:
```
https://my.galaxycloud.app/seowebchecker/us-east-1/deploy
```

### Step 2: Choose Hostname & Region
- **Hostname / Domain**: `seowebchecker.sandbox.galaxycloud.app` (Galaxy sandbox domain).
- **Region**: `us-east-1` (US East, AWS).

### Step 3: Connect GitHub Repository
Under the **Source Code** section:
- Select **Git / GitHub**.
- If not connected, authorize Galaxy to access your GitHub repositories.
- **Repository**: Choose `jaiganesh6999/seowebchecker-seoaudit-sdk`.
- **Branch**: Select `main`.
- **Root Directory**: Enter `meteor-app` (crucial: this points Galaxy to the directory containing `.meteor`).

### Step 4: Environment & Settings
- **Meteor Settings**: Paste the contents of `meteor-app/settings.json` or upload the file.
- **MongoDB**: If prompted for a `MONGO_URL`, provide a free MongoDB connection string (e.g. from MongoDB Atlas M0 cluster or Galaxy's shared MongoDB).

### Step 5: Deploy
- Click the green **"Deploy App"** button!
- Galaxy will launch a container, build the Meteor 3.0 bundle, and start your service.

---

## 💻 Alternative: Deploy via Meteor CLI

If you have the `meteor` CLI installed locally:

```bash
cd meteor-app
meteor login
meteor deploy seowebchecker.sandbox.galaxycloud.app --settings settings.json --owner seowebchecker
```

---

## 📡 Live Endpoints Provided by Your Galaxy App

Once deployed, your live Galaxy service will serve:

| Route | Method | Description |
| :--- | :---: | :--- |
| `/` | `GET` | Interactive Web Dashboard at `https://seowebchecker.sandbox.galaxycloud.app/` |
| `/api/score?url=https://moz.com` | `GET` | Technical SEO health score & grade |
| `/api/meta?url=https://moz.com` | `GET` | Title, description, canonical, OpenGraph |
| `/api/vitals?url=https://moz.com` | `GET` | Response time, TTFB, and payload diagnostics |
| `/api/images?url=https://moz.com` | `GET` | Image alt attributes & modern formats count |
| `/api/audit` | `POST` | Full 50+ check technical audit report |
