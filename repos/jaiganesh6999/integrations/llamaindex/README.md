# LlamaIndex SEOWebChecker Integration 🦙

Official LlamaIndex Tool Specification for automated on-page technical SEO audits, meta tag validation, Open Graph verification, and Core Web Vitals checks.

Compatible with **LlamaHub** ([https://llamahub.ai/](https://llamahub.ai/)).

- **Official Web Suite:** [https://seowebchecker.com/](https://seowebchecker.com/)
- **Documentation:** [https://seo-ai-tools.readthedocs.io/en/latest/](https://seo-ai-tools.readthedocs.io/en/latest/)

---

## ⚡ Installation

```bash
pip install seowebchecker-seoaudit-sdk llama-index
```

---

## 🛠️ Available Methods in `SEOWebCheckerToolSpec`

| Tool Name | Method | Description |
| :--- | :--- | :--- |
| `audit` | `spec.audit(url)` | Full technical SEO diagnostic returning 0–100 health score, grade, category evaluations, and prioritized corrective fixes. |
| `quick_score` | `spec.quick_score(url)` | Fast 0–100 SEO score retrieval with category score breakdowns. |
| `check_meta` | `spec.check_meta(url)` | Validates `<title>`, `<meta name="description">`, canonical links, mobile viewport, and social card previews. |

---

## 🤖 Example: LlamaIndex Function Calling Agent

```python
from llama_index.llms.openai import OpenAI
from llama_index.core.agent import FunctionCallingAgent
from seowebchecker_seoaudit.integrations import SEOWebCheckerToolSpec

# 1. Initialize SEOWebChecker tool spec and convert to tool list
seo_spec = SEOWebCheckerToolSpec()
tools = seo_spec.to_tool_list()

# 2. Initialize LLM
llm = OpenAI(model="gpt-4o")

# 3. Create autonomous agent
agent = FunctionCallingAgent.from_tools(tools, llm=llm, verbose=True)

# 4. Execute audit query
response = agent.chat("Audit https://seowebchecker.com/ and tell me if its canonical tag and viewport are valid.")
print(str(response))
```

---

## 📄 License

MIT License. See [LICENSE](../../LICENSE) for details.
