# Langflow Custom Component: SEOWebChecker SEO Audit

Connect the official **SEOWebChecker SEO Audit** tool into [Langflow](https://www.langflow.org/) AI agent pipelines and multi-agent flows.

[![Langflow](https://img.shields.io/badge/Langflow-Custom%20Component-10B981.svg)](https://www.langflow.org/)
[![SEOWebChecker](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)

---

## 🚀 How to Use in Langflow

### Method 1: Direct Component Import (Drag & Drop)
1. Open your Langflow canvas (local or cloud at `https://langflow.org/`).
2. Click **Custom Component** under the component sidebar.
3. Replace the starter template with the code from [`seowebchecker_component.py`](./seowebchecker_component.py).
4. Click **Build Component**.
5. Connect:
   - **Target URL** from a text input or agent output.
   - **Audit Data** (Structured `Data` dictionary) or **Summary Text** (formatted string) to your LLM Prompt or Agent Tool port.

---

### Method 2: Drop into Custom Component Directory
If running Langflow via Python / Docker:
1. Copy `seowebchecker_component.py` into your Langflow custom components folder (`~/.langflow/components/` or specified directory).
2. The **SEOWebChecker SEO Audit** component will appear under the Custom category in the palette automatically.

---

## 🌐 Official Platform

Full suite and live web dashboard: **[https://seowebchecker.com/](https://seowebchecker.com/)**
