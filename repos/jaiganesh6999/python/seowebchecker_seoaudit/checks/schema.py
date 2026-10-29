"""Structured data (JSON-LD & Schema.org) check engine for SEO audit."""

import json
import re
from typing import Tuple, List, Set
from seowebchecker_seoaudit.models import SchemaInfo, Issue, Severity, Category

try:
    from bs4 import BeautifulSoup
except ImportError:
    BeautifulSoup = None


def extract_schema(html: str) -> Tuple[SchemaInfo, List[Issue]]:
    issues: List[Issue] = []
    schema = SchemaInfo()

    detected_types: Set[str] = set()
    json_ld_blocks: List[str] = []

    if BeautifulSoup:
        soup = BeautifulSoup(html, "html.parser")
        # JSON-LD
        for script in soup.find_all("script", type="application/ld+json"):
            if script.string:
                json_ld_blocks.append(script.string.strip())

        # Microdata
        microdata_items = soup.find_all(attrs={"itemscope": True})
        schema.microdata_count = len(microdata_items)
        for item in microdata_items:
            itemtype = item.get("itemtype")
            if itemtype:
                t_name = itemtype.rsplit("/", 1)[-1]
                detected_types.add(t_name)
    else:
        # Regex fallback
        pattern = re.compile(r'<script[^>]*type=["\']application/ld\+json["\'][^>]*>(.*?)</script>', re.IGNORECASE | re.DOTALL)
        json_ld_blocks = [m.strip() for m in pattern.findall(html) if m.strip()]

        m_micro = re.findall(r'itemscope(?:\s|>)', html, re.IGNORECASE)
        schema.microdata_count = len(m_micro)

    schema.json_ld_count = len(json_ld_blocks)

    def extract_types_from_obj(obj):
        if isinstance(obj, dict):
            t = obj.get("@type")
            if isinstance(t, str):
                detected_types.add(t)
            elif isinstance(t, list):
                for item in t:
                    if isinstance(item, str):
                        detected_types.add(item)
            # Graph list
            graph = obj.get("@graph")
            if isinstance(graph, list):
                for node in graph:
                    extract_types_from_obj(node)
            for v in obj.values():
                if isinstance(v, (dict, list)):
                    extract_types_from_obj(v)
        elif isinstance(obj, list):
            for item in obj:
                extract_types_from_obj(item)

    parse_errors = 0
    for block in json_ld_blocks:
        try:
            data = json.loads(block)
            extract_types_from_obj(data)
        except Exception:
            parse_errors += 1

    schema.detected_types = sorted(list(detected_types))
    schema.has_schema = (schema.json_ld_count > 0 or schema.microdata_count > 0)

    # Rule checks
    if not schema.has_schema:
        issues.append(Issue(
            id="schema-missing",
            category=Category.SCHEMA.value,
            severity=Severity.WARNING,
            title="Missing Structured Data (Schema.org / JSON-LD)",
            message="No JSON-LD or Microdata structured data found on the page.",
            recommendation="Add Schema.org JSON-LD (such as Organization, WebSite, Article, or Product) to be eligible for Google Rich Results.",
            impact_score=5,
        ))
    else:
        if parse_errors > 0:
            issues.append(Issue(
                id="schema-syntax-error",
                category=Category.SCHEMA.value,
                severity=Severity.ERROR,
                title="Invalid JSON-LD Syntax Detected",
                message=f"{parse_errors} JSON-LD block(s) contain invalid syntax and cannot be parsed.",
                recommendation="Validate JSON-LD markup with the Schema Validator or Google Rich Results Test to fix formatting errors.",
                impact_score=6,
            ))

        type_names = ", ".join(schema.detected_types) if schema.detected_types else "Generic Schema"
        issues.append(Issue(
            id="schema-present",
            category=Category.SCHEMA.value,
            severity=Severity.PASS,
            title=f"Structured Data Detected ({len(schema.detected_types)} Types)",
            message=f"Found structured data with schemas: {type_names}.",
            recommendation="Verify schema properties remain updated with current page content.",
            impact_score=0,
        ))

    return schema, issues
