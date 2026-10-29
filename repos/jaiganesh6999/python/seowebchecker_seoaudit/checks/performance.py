"""Performance and payload metrics check engine for SEO audit."""

from typing import Tuple, List, Dict
from seowebchecker_seoaudit.models import PerformanceInfo, Issue, Severity, Category


def extract_performance(
    status_code: int,
    response_time_ms: float,
    content_bytes: bytes,
    headers: Dict[str, str],
) -> Tuple[PerformanceInfo, List[Issue]]:
    issues: List[Issue] = []
    perf = PerformanceInfo()

    perf.status_code = status_code
    perf.response_time_ms = round(response_time_ms, 2)
    perf.page_size_bytes = len(content_bytes)
    perf.page_size_kb = round(perf.page_size_bytes / 1024, 2)

    headers_lower = {k.lower(): v for k, v in headers.items()}
    encoding = headers_lower.get("content-encoding", "").lower()
    perf.content_encoding = encoding or None
    perf.is_compressed = any(c in encoding for c in ["gzip", "br", "deflate", "zstd"])

    # Rule checks
    # HTTP status code
    if status_code != 200:
        if 300 <= status_code < 400:
            issues.append(Issue(
                id="perf-status-redirect",
                category=Category.PERFORMANCE.value,
                severity=Severity.NOTICE,
                title=f"HTTP Redirect ({status_code})",
                message=f"Initial response returned HTTP {status_code} redirect.",
                recommendation="Audit direct target URL to minimize redirect latency.",
                impact_score=2,
            ))
        elif 400 <= status_code < 500:
            issues.append(Issue(
                id="perf-status-client-error",
                category=Category.PERFORMANCE.value,
                severity=Severity.ERROR,
                title=f"Client Error ({status_code})",
                message=f"Server returned HTTP {status_code} client error.",
                recommendation="Ensure the URL is publicly reachable and returns a 200 OK status.",
                impact_score=10,
            ))
        elif status_code >= 500:
            issues.append(Issue(
                id="perf-status-server-error",
                category=Category.PERFORMANCE.value,
                severity=Severity.ERROR,
                title=f"Server Error ({status_code})",
                message=f"Server failed with HTTP {status_code}.",
                recommendation="Fix backend application error or server configuration.",
                impact_score=10,
            ))
    else:
        issues.append(Issue(
            id="perf-status-ok",
            category=Category.PERFORMANCE.value,
            severity=Severity.PASS,
            title="HTTP 200 OK Status",
            message="Server responded with standard 200 OK status.",
            recommendation="Endpoint is live and accessible.",
            impact_score=0,
        ))

    # Response time
    if perf.response_time_ms > 0:
        if perf.response_time_ms > 2000:
            issues.append(Issue(
                id="perf-response-critical-slow",
                category=Category.PERFORMANCE.value,
                severity=Severity.ERROR,
                title=f"Severely Slow Response Time ({perf.response_time_ms} ms)",
                message=f"Initial server response took {perf.response_time_ms} ms (> 2.0s).",
                recommendation="Optimize server response time (TTFB) via edge caching, database query tuning, or a CDN.",
                impact_score=8,
            ))
        elif perf.response_time_ms > 800:
            issues.append(Issue(
                id="perf-response-slow",
                category=Category.PERFORMANCE.value,
                severity=Severity.WARNING,
                title=f"Slow Response Time ({perf.response_time_ms} ms)",
                message=f"Server response time is {perf.response_time_ms} ms (recommended: < 600 ms).",
                recommendation="Use page caching or a content delivery network (CDN) to reduce latency.",
                impact_score=4,
            ))
        elif perf.response_time_ms < 400:
            issues.append(Issue(
                id="perf-response-fast",
                category=Category.PERFORMANCE.value,
                severity=Severity.PASS,
                title=f"Fast Server Response ({perf.response_time_ms} ms)",
                message=f"Excellent TTFB / response time of {perf.response_time_ms} ms.",
                recommendation="Keep server latency low.",
                impact_score=0,
            ))

    # Page size
    if perf.page_size_kb > 300:
        issues.append(Issue(
            id="perf-html-bloated",
            category=Category.PERFORMANCE.value,
            severity=Severity.WARNING,
            title=f"Large HTML Document ({perf.page_size_kb} KB)",
            message=f"Raw HTML document size is {perf.page_size_kb} KB (> 300 KB). Large documents increase DOM parsing time.",
            recommendation="Minify HTML and defer non-critical inline styles/scripts to external bundles.",
            impact_score=4,
        ))
    elif perf.page_size_kb > 0:
        issues.append(Issue(
            id="perf-html-optimal-size",
            category=Category.PERFORMANCE.value,
            severity=Severity.PASS,
            title=f"Optimal Document Size ({perf.page_size_kb} KB)",
            message=f"HTML payload is light and fast to parse ({perf.page_size_kb} KB).",
            recommendation="Maintain lightweight HTML structure.",
            impact_score=0,
        ))

    # Compression
    if not perf.is_compressed and perf.page_size_bytes > 1500:
        issues.append(Issue(
            id="perf-compression-missing",
            category=Category.PERFORMANCE.value,
            severity=Severity.WARNING,
            title="Text Compression Not Enabled",
            message="No gzip or brotli content-encoding detected on the server response.",
            recommendation="Enable Gzip or Brotli compression on your web server to reduce data transfer by up to 70%.",
            impact_score=5,
        ))
    elif perf.is_compressed:
        issues.append(Issue(
            id="perf-compression-active",
            category=Category.PERFORMANCE.value,
            severity=Severity.PASS,
            title=f"Server Compression Active ({perf.content_encoding})",
            message=f"Response is compressed using {perf.content_encoding}.",
            recommendation="Compression is properly configured.",
            impact_score=0,
        ))

    return perf, issues
