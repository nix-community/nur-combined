"""SEO Auditor engine coordinating comprehensive website audits."""

import datetime
import time
import urllib.request
import urllib.error
from urllib.parse import urlparse, urljoin
from typing import Dict, List, Optional

from seowebchecker_seoaudit.models import (
    AuditResult,
    SeoScore,
    CategoryScore,
    Issue,
    Severity,
    Category,
)
from seowebchecker_seoaudit.checks import (
    extract_meta,
    extract_content,
    extract_links,
    extract_images,
    extract_social,
    extract_technical,
    extract_performance,
    extract_schema,
)

try:
    import requests
except ImportError:
    requests = None


DEFAULT_USER_AGENT = "SEOWebChecker-AuditBot/1.0 (+https://seowebchecker.com/)"


class SEOAuditor:
    """Lightweight, comprehensive SEO audit analyzer."""

    def __init__(
        self,
        user_agent: str = DEFAULT_USER_AGENT,
        timeout: int = 15,
        check_robots: bool = True,
        check_sitemap: bool = True,
        custom_headers: Optional[Dict[str, str]] = None,
    ):
        self.user_agent = user_agent
        self.timeout = timeout
        self.check_robots = check_robots
        self.check_sitemap = check_sitemap
        self.custom_headers = custom_headers or {}

    def _get_headers(self) -> Dict[str, str]:
        headers = {
            "User-Agent": self.user_agent,
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.9",
            "Accept-Encoding": "gzip, deflate, identity",
        }
        headers.update(self.custom_headers)
        return headers

    def _fetch_url(self, url: str) -> tuple[int, bytes, Dict[str, str], float]:
        start = time.perf_counter()
        headers = self._get_headers()

        if requests is not None:
            resp = requests.get(
                url,
                headers=headers,
                timeout=self.timeout,
                allow_redirects=True,
            )
            elapsed_ms = (time.perf_counter() - start) * 1000.0
            return resp.status_code, resp.content, dict(resp.headers), elapsed_ms
        else:
            req = urllib.request.Request(url, headers=headers)
            try:
                with urllib.request.urlopen(req, timeout=self.timeout) as response:
                    elapsed_ms = (time.perf_counter() - start) * 1000.0
                    content = response.read()
                    resp_headers = dict(response.headers)
                    enc = resp_headers.get("Content-Encoding", "").lower()
                    if "gzip" in enc or (len(content) > 2 and content[:2] == b"\x1f\x8b"):
                        try:
                            import gzip
                            content = gzip.decompress(content)
                        except Exception:
                            pass
                    elif "deflate" in enc:
                        try:
                            import zlib
                            content = zlib.decompress(content)
                        except Exception:
                            pass
                    return response.status, content, resp_headers, elapsed_ms
            except urllib.error.HTTPError as e:
                elapsed_ms = (time.perf_counter() - start) * 1000.0
                content = e.read() if hasattr(e, "read") else b""
                resp_headers = dict(e.headers) if hasattr(e, "headers") else {}
                return e.code, content, resp_headers, elapsed_ms
            except Exception as e:
                elapsed_ms = (time.perf_counter() - start) * 1000.0
                return 0, str(e).encode(), {}, elapsed_ms

    def _probe_resource(self, base_url: str, path: str) -> Optional[bool]:
        parsed = urlparse(base_url)
        target = f"{parsed.scheme}://{parsed.netloc}/{path.lstrip('/')}"
        headers = {"User-Agent": self.user_agent}

        try:
            if requests is not None:
                r = requests.head(target, headers=headers, timeout=5, allow_redirects=True)
                return r.status_code == 200
            else:
                req = urllib.request.Request(target, headers=headers, method="HEAD")
                with urllib.request.urlopen(req, timeout=5) as resp:
                    return resp.status == 200
        except Exception:
            return False

    def audit_html(
        self,
        html: str,
        url: str = "https://seowebchecker.com/",
        headers: Optional[Dict[str, str]] = None,
        status_code: int = 200,
        response_time_ms: float = 120.0,
        robots_found: Optional[bool] = None,
        sitemap_found: Optional[bool] = None,
    ) -> AuditResult:
        """Audit an HTML string directly without making external network requests."""
        headers = headers or {}
        content_bytes = html.encode("utf-8", errors="ignore")

        # Run checks
        meta_info, meta_issues = extract_meta(html)
        content_info, content_issues = extract_content(html)
        links_info, links_issues = extract_links(html, base_url=url)
        images_info, images_issues = extract_images(html)
        social_info, social_issues = extract_social(html)
        tech_info, tech_issues = extract_technical(url, headers, robots_found, sitemap_found)
        perf_info, perf_issues = extract_performance(status_code, response_time_ms, content_bytes, headers)
        schema_info, schema_issues = extract_schema(html)

        all_issues = (
            meta_issues
            + content_issues
            + links_issues
            + images_issues
            + social_issues
            + tech_issues
            + perf_issues
            + schema_issues
        )

        # Calculate scores
        score = self._compute_scores(all_issues)

        timestamp = datetime.datetime.now(datetime.timezone.utc).isoformat()

        return AuditResult(
            url=url,
            timestamp=timestamp,
            score=score,
            meta=meta_info,
            content=content_info,
            links=links_info,
            images=images_info,
            social=social_info,
            technical=tech_info,
            performance=perf_info,
            schema=schema_info,
            issues=all_issues,
        )

    def audit(self, url: str) -> AuditResult:
        """Perform a full live audit against a target URL."""
        if not url.startswith(("http://", "https://")):
            url = "https://" + url

        status_code, content_bytes, resp_headers, elapsed_ms = self._fetch_url(url)

        # Decode HTML
        try:
            html = content_bytes.decode("utf-8")
        except UnicodeDecodeError:
            try:
                html = content_bytes.decode("latin-1")
            except Exception:
                html = str(content_bytes)

        # Probes
        robots_found = None
        sitemap_found = None
        if self.check_robots:
            robots_found = self._probe_resource(url, "/robots.txt")
        if self.check_sitemap:
            sitemap_found = self._probe_resource(url, "/sitemap.xml")

        return self.audit_html(
            html=html,
            url=url,
            headers=resp_headers,
            status_code=status_code,
            response_time_ms=elapsed_ms,
            robots_found=robots_found,
            sitemap_found=sitemap_found,
        )

    def _compute_scores(self, issues: List[Issue]) -> SeoScore:
        # Group issues by category
        cat_map: Dict[str, List[Issue]] = {}
        for issue in issues:
            cat_map.setdefault(issue.category, []).append(issue)

        cat_scores: Dict[str, CategoryScore] = {}
        category_weights = {
            Category.META.value: 0.22,
            Category.CONTENT.value: 0.18,
            Category.TECHNICAL.value: 0.18,
            Category.PERFORMANCE.value: 0.14,
            Category.LINKS.value: 0.10,
            Category.IMAGES.value: 0.08,
            Category.SOCIAL.value: 0.05,
            Category.SCHEMA.value: 0.05,
        }

        weighted_sum = 0.0
        weight_total = 0.0

        for cat_name, issues_in_cat in cat_map.items():
            passed = sum(1 for i in issues_in_cat if i.severity == Severity.PASS)
            warnings = sum(1 for i in issues_in_cat if i.severity == Severity.WARNING)
            errors = sum(1 for i in issues_in_cat if i.severity == Severity.ERROR)
            notices = sum(1 for i in issues_in_cat if i.severity == Severity.NOTICE)

            total = passed + warnings + errors + notices
            if total > 0:
                # Base score from passing proportion
                score_raw = (passed / total) * 100.0
                # Extra deduction for critical errors
                score_raw -= (errors * 10.0)
                # Slight deduction for warnings
                score_raw -= (warnings * 3.0)
                final_cat_score = max(0, min(100, int(round(score_raw))))
            else:
                final_cat_score = 100

            cat_scores[cat_name] = CategoryScore(
                name=cat_name,
                score=final_cat_score,
                passed_count=passed,
                warning_count=warnings,
                error_count=errors,
            )

            w = category_weights.get(cat_name, 0.1)
            weighted_sum += final_cat_score * w
            weight_total += w

        overall = int(round(weighted_sum / weight_total)) if weight_total > 0 else 80
        overall = max(0, min(100, overall))
        grade = SeoScore.calculate_grade(overall)

        return SeoScore(
            overall=overall,
            grade=grade,
            categories=cat_scores,
        )
