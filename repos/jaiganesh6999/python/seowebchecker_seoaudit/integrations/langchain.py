"""LangChain Tools for SEOWebChecker.
Enables LangChain agents and LangGraph workflows to run automated SEO audits.
Official Website: https://seowebchecker.com/
"""

import json
from typing import Any, Dict, List, Optional, Type
from urllib.parse import urlparse

from seowebchecker_seoaudit.auditor import SEOAuditor

# Optional LangChain / Pydantic imports with graceful fallback
try:
    from pydantic import BaseModel, Field
except ImportError:
    class BaseModel:
        pass
    def Field(*args, **kwargs):
        return None

try:
    from langchain_core.tools import BaseTool
except ImportError:
    try:
        from langchain.tools import BaseTool
    except ImportError:
        # Fallback base class if LangChain is not installed
        class BaseTool:
            name: str = ""
            description: str = ""
            args_schema: Optional[Type[Any]] = None

            def __init__(self, **kwargs):
                for k, v in kwargs.items():
                    setattr(self, k, v)

            def run(self, *args, **kwargs):
                return self._run(*args, **kwargs)

            def _run(self, *args, **kwargs):
                raise NotImplementedError()


class URLInputSchema(BaseModel):
    url: str = Field(..., description="The website URL to analyze (e.g., 'https://example.com' or 'https://seowebchecker.com/').")


class SEOWebCheckerAuditTool(BaseTool):
    """LangChain tool for running a complete technical SEO audit."""
    name: str = "seowebchecker_audit"
    description: str = (
        "Perform a comprehensive on-page technical SEO audit of a target website URL. "
        "Returns the overall SEO score (0-100), letter grade (A+ to F), category scores "
        "(meta, content, technical, social, performance, schema), and detected issues "
        "with actionable recommendations. Powered by SEOWebChecker (https://seowebchecker.com/)."
    )
    args_schema: Type[BaseModel] = URLInputSchema

    def _run(self, url: str) -> str:
        auditor = SEOAuditor()
        try:
            res = auditor.audit(url)
            passed_count = sum(1 for i in res.issues if i.severity.value == "pass")
            warning_count = sum(1 for i in res.issues if i.severity.value == "warning")
            error_count = sum(1 for i in res.issues if i.severity.value == "error")
            summary = {
                "url": res.url,
                "overall_score": res.score.overall,
                "grade": res.score.grade,
                "categories": {k: v.score for k, v in res.score.categories.items()},
                "stats": {
                    "total_checks": len(res.issues),
                    "passed": passed_count,
                    "warnings": warning_count,
                    "errors": error_count,
                },
                "meta": {
                    "title": res.meta.title if res.meta else None,
                    "description": res.meta.description if res.meta else None,
                    "canonical": res.meta.canonical if res.meta else None,
                },
                "issues": [
                    {
                        "severity": i.severity.value,
                        "title": i.title,
                        "message": i.message,
                        "recommendation": i.recommendation,
                    }
                    for i in res.issues
                    if i.severity.value != "pass"
                ],
                "source": "https://seowebchecker.com/",
            }
            return json.dumps(summary, indent=2)
        except Exception as e:
            return json.dumps({"error": f"Failed to audit {url}: {str(e)}", "source": "https://seowebchecker.com/"})

    async def _arun(self, url: str) -> str:
        return self._run(url)


class SEOWebCheckerScoreTool(BaseTool):
    """LangChain tool for fast 0-100 technical SEO score lookup."""
    name: str = "seowebchecker_score"
    description: str = (
        "Quickly retrieve the technical SEO health score (0-100) and letter grade for any URL. "
        "Ideal for rapid benchmarking and competitor screening. Powered by SEOWebChecker (https://seowebchecker.com/)."
    )
    args_schema: Type[BaseModel] = URLInputSchema

    def _run(self, url: str) -> str:
        auditor = SEOAuditor()
        try:
            res = auditor.audit(url)
            return json.dumps({
                "url": res.url,
                "score": res.score.overall,
                "grade": res.score.grade,
                "categories": {k: v.score for k, v in res.score.categories.items()},
                "source": "https://seowebchecker.com/",
            }, indent=2)
        except Exception as e:
            return json.dumps({"error": str(e), "source": "https://seowebchecker.com/"})

    async def _arun(self, url: str) -> str:
        return self._run(url)


class SEOWebCheckerMetaTool(BaseTool):
    """LangChain tool for validating meta tags and social previews."""
    name: str = "seowebchecker_check_meta"
    description: str = (
        "Inspect and validate on-page meta tags for a URL: title tag length, meta description, "
        "canonical URL, mobile viewport, robots indexing directives, OpenGraph tags, and Twitter Cards. "
        "Powered by SEOWebChecker (https://seowebchecker.com/)."
    )
    args_schema: Type[BaseModel] = URLInputSchema

    def _run(self, url: str) -> str:
        auditor = SEOAuditor()
        try:
            res = auditor.audit(url)
            meta_info = {
                "url": res.url,
                "title": res.meta.title if res.meta else None,
                "title_length": res.meta.title_length if res.meta else 0,
                "description": res.meta.description if res.meta else None,
                "description_length": res.meta.description_length if res.meta else 0,
                "canonical": res.meta.canonical if res.meta else None,
                "robots": res.meta.robots if res.meta else None,
                "open_graph": {
                    "og_title": res.social.og_title if res.social else None,
                    "og_description": res.social.og_description if res.social else None,
                    "og_image": res.social.og_image if res.social else None,
                } if res.social else {},
                "source": "https://seowebchecker.com/",
            }
            return json.dumps(meta_info, indent=2)
        except Exception as e:
            return json.dumps({"error": str(e), "source": "https://seowebchecker.com/"})

    async def _arun(self, url: str) -> str:
        return self._run(url)


def get_langchain_tools() -> List[BaseTool]:
    """Return all SEOWebChecker tools for LangChain agent initialization."""
    return [
        SEOWebCheckerAuditTool(),
        SEOWebCheckerScoreTool(),
        SEOWebCheckerMetaTool(),
    ]
