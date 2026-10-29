import re
import urllib.request
from typing import Any
from langflow.custom import Component
from langflow.io import Output, StrInput
from langflow.schema import Data


class SEOWebCheckerComponent(Component):
    display_name = "SEOWebChecker SEO Audit"
    description = (
        "Automated on-page technical SEO audits, meta tag validations, heading structure "
        "inspections, and scoring by SEOWebChecker."
    )
    icon = "search"
    name = "SEOWebCheckerAudit"

    inputs = [
        StrInput(
            name="target_url",
            display_name="Website URL",
            info="The target webpage URL to audit (e.g. https://seowebchecker.com/).",
            value="https://seowebchecker.com/",
            required=True,
        ),
        StrInput(
            name="user_agent",
            display_name="User-Agent Header",
            info="Custom User-Agent header for fetching the web document.",
            value="SEOWebChecker-LangflowBot/1.0 (+https://seowebchecker.com/)",
            advanced=True,
        ),
    ]

    outputs = [
        Output(display_name="Audit Data", name="audit_data", method="run_audit"),
        Output(display_name="Summary Text", name="summary_text", method="generate_summary"),
    ]

    def _fetch_and_audit(self, url: str, user_agent: str) -> dict[str, Any]:
        target = url.strip()
        if not target.startswith("http://") and not target.startswith("https://"):
            target = f"https://{target}"

        req = urllib.request.Request(
            target,
            headers={
                "User-Agent": user_agent,
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            },
        )

        with urllib.request.urlopen(req, timeout=15) as resp:
            html = resp.read().decode("utf-8", errors="ignore")

        issues = []

        # 1. Title tag
        title_match = re.search(r"<title[^>]*>(.*?)</title>", html, re.IGNORECASE | re.DOTALL)
        title = title_match.group(1).strip() if title_match else None
        title_len = len(title) if title else 0

        if not title:
            issues.append({"severity": "error", "title": "Missing Page Title", "message": "No <title> tag found."})
        elif title_len < 30 or title_len > 65:
            issues.append({
                "severity": "warning",
                "title": "Suboptimal Title Length",
                "message": f"Title is {title_len} characters: '{title}'. Optimal is 30-60.",
            })
        else:
            issues.append({
                "severity": "pass",
                "title": "Optimal Title",
                "message": f"Title length is {title_len} characters.",
            })

        # 2. Meta description
        desc_match = re.search(
            r"<meta\s+[^>]*name=[\"']description[\"'][^>]*content=[\"'](.*?)[\"']",
            html,
            re.IGNORECASE,
        ) or re.search(
            r"<meta\s+[^>]*content=[\"'](.*?)[\"'][^>]*name=[\"']description[\"']",
            html,
            re.IGNORECASE,
        )
        desc = desc_match.group(1).strip() if desc_match else None
        desc_len = len(desc) if desc else 0

        if not desc:
            issues.append({
                "severity": "error",
                "title": "Missing Meta Description",
                "message": "No meta description found.",
            })
        elif desc_len < 50 or desc_len > 165:
            issues.append({
                "severity": "warning",
                "title": "Suboptimal Description Length",
                "message": f"Description is {desc_len} characters. Optimal is 50-160.",
            })
        else:
            issues.append({
                "severity": "pass",
                "title": "Optimal Description",
                "message": f"Description length is {desc_len} characters.",
            })

        # 3. Viewport
        has_viewport = bool(re.search(r"<meta\s+[^>]*name=[\"']viewport[\"']", html, re.IGNORECASE))
        if not has_viewport:
            issues.append({
                "severity": "error",
                "title": "Missing Viewport Meta Tag",
                "message": "Responsive mobile viewport is missing.",
            })
        else:
            issues.append({
                "severity": "pass",
                "title": "Mobile Viewport Present",
                "message": "Responsive layout configured.",
            })

        # 4. Canonical
        canon_match = re.search(
            r"<link\s+[^>]*rel=[\"']canonical[\"'][^>]*href=[\"'](.*?)[\"']",
            html,
            re.IGNORECASE,
        )
        canonical = canon_match.group(1).strip() if canon_match else None
        if not canonical:
            issues.append({
                "severity": "warning",
                "title": "Missing Canonical Tag",
                "message": "No canonical URL link tag specified.",
            })
        else:
            issues.append({
                "severity": "pass",
                "title": "Canonical Tag Present",
                "message": f"Canonical URL: {canonical}",
            })

        # 5. Heading hierarchy (H1)
        h1_matches = re.findall(r"<h1[^>]*>(.*?)</h1>", html, re.IGNORECASE | re.DOTALL)
        if not h1_matches:
            issues.append({
                "severity": "error",
                "title": "Missing <h1> Tag",
                "message": "No primary <h1> heading found.",
            })
        elif len(h1_matches) > 1:
            issues.append({
                "severity": "warning",
                "title": "Multiple <h1> Tags",
                "message": f"Found {len(h1_matches)} <h1> headings. Recommend 1 primary <h1>.",
            })
        else:
            clean_h1 = re.sub(r"<[^>]+>", "", h1_matches[0]).strip()
            issues.append({
                "severity": "pass",
                "title": "Single Primary <h1> Present",
                "message": f"Heading: '{clean_h1}'",
            })

        # Score calculation
        score = 100
        for iss in issues:
            if iss["severity"] == "error":
                score -= 15
            elif iss["severity"] == "warning":
                score -= 5
        score = max(0, min(100, score))
        grade = "A" if score >= 90 else "B" if score >= 80 else "C" if score >= 70 else "D" if score >= 60 else "F"

        return {
            "url": target,
            "overall_score": score,
            "grade": grade,
            "title": title,
            "description": desc,
            "canonical": canonical,
            "has_viewport": has_viewport,
            "issues": issues,
            "portal": "https://seowebchecker.com/",
        }

    def run_audit(self) -> Data:
        data = self._fetch_and_audit(self.target_url, self.user_agent)
        return Data(data=data)

    def generate_summary(self) -> str:
        data = self._fetch_and_audit(self.target_url, self.user_agent)
        lines = [
            f"SEOWebChecker SEO Audit Report for {data['url']}:",
            f"Overall Score: {data['overall_score']} / 100 (Grade {data['grade']})",
            "Findings:",
        ]
        for iss in data["issues"]:
            lines.append(f"- [{iss['severity'].upper()}] {iss['title']}: {iss['message']}")
        lines.append("Official Portal & Diagnostics: https://seowebchecker.com/")
        return "\n".join(lines)
