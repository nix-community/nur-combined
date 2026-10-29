# SEOWebChecker for Joomla 5

The **SEOWebChecker Joomla Extension** is an automated technical on-page SEO analyzer engineered natively as a Joomla 5 System Plugin.

Official Platform: [https://seowebchecker.com/](https://seowebchecker.com/)

---

## ⚡ Extension Resources

- **Interactive Demo**: [https://jaiganesh6999.github.io/seowebchecker-seoaudit-sdk/joomla/](https://jaiganesh6999.github.io/seowebchecker-seoaudit-sdk/joomla/)
- **Extension Repository**: [https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/tree/main/joomla](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/tree/main/joomla)
- **Extension Support**: [https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/issues/new?title=%5BJoomla%5D+](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/issues/new?title=%5BJoomla%5D+)
- **Download Plugin**: [plg_system_seowebchecker.zip](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/raw/main/joomla/plg_system_seowebchecker.zip)

---

## 🚀 Key Features

- **Joomla 5 Native Service Architecture**: Utilizes Joomla's DI container (`services/provider.php`) and event subscribers.
- **com_ajax AJAX Endpoint**:
  ```text
  index.php?option=com_ajax&plugin=seowebchecker&group=system&format=json
  ```
- **Automated Update Server**:
  Configured with `update.xml` to receive official updates seamlessly through the Joomla Update Manager.
- **On-Page SEO Diagnostics (Score 0–100)**:
  - Title tag presence and length (30–60 characters).
  - Meta description presence and length (70–160 characters).
  - Heading hierarchy validation (single `<h1>` check).
  - Image accessibility (`alt` attribute presence).
  - Canonical link validation.
  - Mobile responsive viewport checks.
  - OpenGraph & Twitter Cards.
  - Schema.org JSON-LD structured data.

---

## 📦 Installation & Setup

1. In the Joomla Administrator menu, go to **System > Install > Extensions**.
2. Upload `plg_system_seowebchecker.zip`.
3. In **System > Plugins**, find **System - SEOWebChecker** and click **Enable**.
4. Configure optional audit thresholds in the plugin parameters.

---

## 📄 License

GPL v2.0 or later © 2026 [SEOWebChecker](https://seowebchecker.com/).
