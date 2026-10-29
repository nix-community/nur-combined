# LangChain SEOWebChecker Integration 🦜🔗

Official LangChain toolkit for automated on-page technical SEO audits, meta tag validation, Open Graph verification, and Core Web Vitals checks.

- **Official Web Suite:** [https://seowebchecker.com/](https://seowebchecker.com/)
- **Documentation:** [https://seo-ai-tools.readthedocs.io/en/latest/](https://seo-ai-tools.readthedocs.io/en/latest/)

---

## ⚡ Installation

```bash
pip install seowebchecker-seoaudit-sdk langchain langchain-core
```

---

## 🛠️ Available Tools

| Tool Name | Class | Description |
| :--- | :--- | :--- |
| `seowebchecker_audit` | `SEOWebCheckerAuditTool` | Comprehensive 50+ check technical audit returning 0–100 score, letter grade, and prioritized recommendations. |
| `seowebchecker_score` | `SEOWebCheckerScoreTool` | Rapid 0–100 health score calculation with category breakdown for high-throughput screening. |
| `seowebchecker_check_meta` | `SEOWebCheckerMetaTool` | Validates title, meta description, canonical URL, mobile viewport, robots directives, and OpenGraph/Twitter previews. |

---

## 🤖 Example: LangChain Autonomous SEO Agent

```python
from langchain_openai import ChatOpenAI
from langchain.agents import create_react_agent, AgentExecutor
from langchain import hub
from seowebchecker_seoaudit.integrations import get_langchain_tools

# 1. Load SEOWebChecker tools
tools = get_langchain_tools()

# 2. Initialize LLM
llm = ChatOpenAI(model="gpt-4o", temperature=0)

# 3. Pull prompt and build agent
prompt = hub.pull("hwchase17/react")
agent = create_react_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

# 4. Run autonomous audit
response = agent_executor.invoke({
    "input": "Audit the website https://seowebchecker.com/ and summarize the top SEO priorities."
})

print(response["output"])
```

---

## 📄 License

MIT License. See [LICENSE](../../LICENSE) for details.
