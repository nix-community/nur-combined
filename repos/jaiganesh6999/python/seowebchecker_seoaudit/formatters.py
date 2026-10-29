"""Output formatters for SEO audit results (Console, Markdown, HTML)."""

import html
from typing import List
from seowebchecker_seoaudit.models import AuditResult, Severity


class ConsoleColor:
    RESET = "\033[0m"
    BOLD = "\033[1m"
    DIM = "\033[2m"
    RED = "\033[91m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    BLUE = "\033[94m"
    MAGENTA = "\033[95m"
    CYAN = "\033[96m"
    WHITE = "\033[97m"
    BG_GREEN = "\033[42m\033[30m"
    BG_YELLOW = "\033[43m\033[30m"
    BG_RED = "\033[41m\033[97m"


def format_console(result: AuditResult, use_color: bool = True) -> str:
    """Format an AuditResult into an attractive terminal output."""
    c = ConsoleColor if use_color else type("NoColor", (), {k: "" for k in dir(ConsoleColor) if not k.startswith("_")})()

    score = result.score.overall
    grade = result.score.grade

    if score >= 90:
        score_color = c.GREEN
        badge = f"{c.BG_GREEN} GRADE {grade} ({score}/100) {c.RESET}"
    elif score >= 70:
        score_color = c.YELLOW
        badge = f"{c.BG_YELLOW} GRADE {grade} ({score}/100) {c.RESET}"
    else:
        score_color = c.RED
        badge = f"{c.BG_RED} GRADE {grade} ({score}/100) {c.RESET}"

    lines = []
    lines.append(f"{c.CYAN}{'=' * 68}{c.RESET}")
    lines.append(f"{c.BOLD} SEOWebChecker SEO Audit Report: {result.url}{c.RESET}")
    lines.append(f" {c.DIM}Official Tool: https://seowebchecker.com/ | Timestamp: {result.timestamp}{c.RESET}")
    lines.append(f"{c.CYAN}{'=' * 68}{c.RESET}\n")

    lines.append(f" Overall Score: {score_color}{c.BOLD}{score}/100{c.RESET}  |  Grade: {badge}")
    lines.append(f" Checks: {c.GREEN}{len(result.passed_issues)} Passed{c.RESET}, "
                 f"{c.YELLOW}{len(result.warnings)} Warnings{c.RESET}, "
                 f"{c.RED}{len(result.errors)} Errors{c.RESET}, "
                 f"{c.BLUE}{len(result.notices)} Notices{c.RESET}\n")

    lines.append(f"{c.BOLD}Category Breakdown:{c.RESET}")
    for cat_name, cat in result.score.categories.items():
        bar_len = int(cat.score / 5)
        bar = "█" * bar_len + "░" * (20 - bar_len)
        cat_color = c.GREEN if cat.score >= 85 else (c.YELLOW if cat.score >= 70 else c.RED)
        lines.append(f"  • {cat_name.title():<14} [{cat_color}{bar}{c.RESET}] {cat_color}{cat.score:>3}/100{c.RESET} "
                     f"({cat.passed_count} pass, {cat.warning_count} warn, {cat.error_count} err)")

    # Key metadata summary
    lines.append(f"\n{c.BOLD}Core Metadata & Signals:{c.RESET}")
    lines.append(f"  • Title: {result.meta.title or '[MISSING]'} ({result.meta.title_length} chars)")
    lines.append(f"  • Meta Description: {result.meta.description or '[MISSING]'} ({result.meta.description_length} chars)")
    lines.append(f"  • Canonical: {result.meta.canonical or '[MISSING]'}")
    lines.append(f"  • Word Count: {result.content.word_count} words (~{result.content.reading_time_minutes} min read)")
    lines.append(f"  • Headings: H1={len(result.content.h1_tags)}, H2={len(result.content.h2_tags)}, H3={len(result.content.h3_tags)}")
    lines.append(f"  • Links: Total={result.links.total_links}, Internal={result.links.internal_links}, External={result.links.external_links}")
    lines.append(f"  • Images: Total={result.images.total_images}, Missing Alt={result.images.missing_alt}")
    lines.append(f"  • Technical: HTTPS={'Yes' if result.technical.is_https else 'No'}, HSTS={'Yes' if result.technical.hsts_enabled else 'No'}, Response Time={result.performance.response_time_ms}ms")

    # Errors & Warnings
    if result.errors:
        lines.append(f"\n{c.RED}{c.BOLD}[!] High Priority Issues (Errors):{c.RESET}")
        for err in result.errors:
            lines.append(f"  {c.RED}✖ {err.title}{c.RESET}")
            lines.append(f"    Message: {err.message}")
            lines.append(f"    Action:  {c.DIM}{err.recommendation}{c.RESET}")

    if result.warnings:
        lines.append(f"\n{c.YELLOW}{c.BOLD}[~] Recommended Improvements (Warnings):{c.RESET}")
        for warn in result.warnings:
            lines.append(f"  {c.YELLOW}▲ {warn.title}{c.RESET}")
            lines.append(f"    Message: {warn.message}")
            lines.append(f"    Action:  {c.DIM}{warn.recommendation}{c.RESET}")

    lines.append(f"\n{c.CYAN}{'-' * 68}{c.RESET}")
    lines.append(f" Run in-depth web audit at: https://seowebchecker.com/")
    lines.append(f"{c.CYAN}{'-' * 68}{c.RESET}")

    return "\n".join(lines)


def format_markdown(result: AuditResult) -> str:
    """Format an AuditResult into clean GitHub-flavored Markdown."""
    lines = []
    lines.append(f"# SEO Audit Report: {result.url}\n")
    lines.append(f"> Audited with [SEOWebChecker](https://seowebchecker.com/) on `{result.timestamp}`\n")

    lines.append(f"## Executive Summary\n")
    lines.append(f"- **Overall Score:** **`{result.score.overall}/100`** (Grade: **{result.score.grade}**)")
    lines.append(f"- **Passed Checks:** `{len(result.passed_issues)}`")
    lines.append(f"- **Warnings:** `{len(result.warnings)}`")
    lines.append(f"- **Errors:** `{len(result.errors)}`")
    lines.append(f"- **Notices:** `{len(result.notices)}`\n")

    lines.append("### Category Scores\n")
    lines.append("| Category | Score | Passed | Warnings | Errors |")
    lines.append("| :--- | :---: | :---: | :---: | :---: |")
    for cat_name, cat in result.score.categories.items():
        lines.append(f"| {cat_name.title()} | **{cat.score}/100** | {cat.passed_count} | {cat.warning_count} | {cat.error_count} |")
    lines.append("")

    lines.append("## On-Page SEO Highlights\n")
    lines.append(f"- **Title:** `{result.meta.title or 'MISSING'}` ({result.meta.title_length} characters)")
    lines.append(f"- **Meta Description:** `{result.meta.description or 'MISSING'}` ({result.meta.description_length} characters)")
    lines.append(f"- **Canonical URL:** `{result.meta.canonical or 'MISSING'}`")
    lines.append(f"- **Word Count:** `{result.content.word_count}` words (~{result.content.reading_time_minutes} min read)")
    lines.append(f"- **Headings Hierarchy:** `{len(result.content.h1_tags)}` H1, `{len(result.content.h2_tags)}` H2, `{len(result.content.h3_tags)}` H3")
    lines.append(f"- **Images:** `{result.images.total_images}` total, `{result.images.missing_alt}` missing `alt` attributes")
    lines.append(f"- **Links:** `{result.links.total_links}` total (`{result.links.internal_links}` internal, `{result.links.external_links}` external)")
    lines.append(f"- **HTTPS / SSL:** `{'Enabled' if result.technical.is_https else 'Insecure (HTTP)'}`")
    lines.append(f"- **Response Time:** `{result.performance.response_time_ms} ms` (Size: `{result.performance.page_size_kb} KB`)\n")

    if result.errors:
        lines.append("## High Priority Issues (Errors)\n")
        for err in result.errors:
            lines.append(f"### ❌ {err.title}")
            lines.append(f"- **Category:** `{err.category}`")
            lines.append(f"- **Issue:** {err.message}")
            lines.append(f"- **Action:** {err.recommendation}\n")

    if result.warnings:
        lines.append("## Recommended Improvements (Warnings)\n")
        for warn in result.warnings:
            lines.append(f"### ⚠️ {warn.title}")
            lines.append(f"- **Category:** `{warn.category}`")
            lines.append(f"- **Issue:** {warn.message}")
            lines.append(f"- **Action:** {warn.recommendation}\n")

    lines.append("## Passed Checks\n")
    for ok in result.passed_issues:
        lines.append(f"- ✅ **{ok.title}**: {ok.message}")
    lines.append("")

    lines.append("---\n*Automate continuous SEO audits in your CI/CD pipeline using [seowebchecker-seoaudit-sdk](https://seowebchecker.com/).*")

    return "\n".join(lines)


def format_html(result: AuditResult) -> str:
    """Generate a self-contained responsive HTML audit report dashboard."""
    score = result.score.overall
    grade = result.score.grade
    color = "#10B981" if score >= 85 else ("#F59E0B" if score >= 70 else "#EF4444")

    issues_html = []
    for issue in result.issues:
        sev = issue.severity.value
        sev_color = {
            "error": "bg-red-100 text-red-700 border-red-200",
            "warning": "bg-amber-100 text-amber-700 border-amber-200",
            "notice": "bg-blue-100 text-blue-700 border-blue-200",
            "pass": "bg-emerald-100 text-emerald-700 border-emerald-200",
        }.get(sev, "bg-gray-100 text-gray-700")

        badge_icon = {"error": "❌", "warning": "⚠️", "notice": "ℹ️", "pass": "✅"}.get(sev, "•")

        issues_html.append(f"""
        <div class="border rounded-lg p-4 mb-3 bg-white shadow-sm">
            <div class="flex items-center justify-between">
                <span class="font-semibold text-gray-800 text-base">{badge_icon} {html.escape(issue.title)}</span>
                <span class="text-xs uppercase font-bold px-2.5 py-1 rounded-full border {sev_color}">{sev}</span>
            </div>
            <p class="text-gray-600 text-sm mt-2">{html.escape(issue.message)}</p>
            {f'<div class="mt-2 text-xs bg-gray-50 border-l-2 border-indigo-500 p-2 text-gray-700 font-mono"><strong>Fix:</strong> {html.escape(issue.recommendation)}</div>' if issue.severity != Severity.PASS else ''}
        </div>
        """)

    cat_rows = []
    for cat_name, cat in result.score.categories.items():
        c_color = "#10B981" if cat.score >= 85 else ("#F59E0B" if cat.score >= 70 else "#EF4444")
        cat_rows.append(f"""
        <div class="p-4 bg-gray-50 rounded-lg">
            <div class="flex justify-between items-center mb-1">
                <span class="font-medium text-gray-700">{cat_name.title()}</span>
                <span class="font-bold text-gray-900">{cat.score}/100</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-2">
                <div class="h-2 rounded-full" style="width: {cat.score}%; background-color: {c_color};"></div>
            </div>
            <div class="text-xs text-gray-500 mt-2">
                {cat.passed_count} Passed • {cat.warning_count} Warnings • {cat.error_count} Errors
            </div>
        </div>
        """)

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SEO Audit Report - {html.escape(result.url)} - SEOWebChecker</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<style>
body {{ font-family: 'Inter', sans-serif; }}
</style>
</head>
<body class="bg-gray-100 min-h-screen text-gray-900">
    <div class="max-w-5xl mx-auto px-4 py-8">
        <!-- Header -->
        <header class="bg-white rounded-xl shadow-sm p-6 mb-6 flex flex-col md:flex-row justify-between items-start md:items-center">
            <div>
                <a href="https://seowebchecker.com/" target="_blank" class="text-xs font-semibold uppercase tracking-wider text-indigo-600 hover:underline">SEOWebChecker Audit Tool</a>
                <h1 class="text-2xl font-extrabold text-gray-900 mt-1 break-all">{html.escape(result.url)}</h1>
                <p class="text-xs text-gray-400 mt-1">Generated: {html.escape(result.timestamp)}</p>
            </div>
            <div class="mt-4 md:mt-0 flex items-center space-x-4">
                <div class="text-center p-3 rounded-xl border-2" style="border-color: {color};">
                    <span class="block text-3xl font-extrabold" style="color: {color};">{score}</span>
                    <span class="text-xs uppercase font-bold text-gray-500">Score / 100</span>
                </div>
                <div class="text-center p-3 rounded-xl bg-gray-900 text-white min-w-[70px]">
                    <span class="block text-3xl font-extrabold">{grade}</span>
                    <span class="text-xs uppercase font-bold text-gray-400">Grade</span>
                </div>
            </div>
        </header>

        <!-- Category Grid -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
            {''.join(cat_rows)}
        </div>

        <!-- Metadata Summary Box -->
        <div class="bg-white rounded-xl shadow-sm p-6 mb-6">
            <h2 class="text-lg font-bold text-gray-900 mb-4">Core Metadata & Page Signals</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                <div><strong>Page Title:</strong> <span class="text-gray-600">{html.escape(result.meta.title or 'N/A')} ({result.meta.title_length} chars)</span></div>
                <div><strong>Meta Description:</strong> <span class="text-gray-600">{html.escape(result.meta.description or 'N/A')} ({result.meta.description_length} chars)</span></div>
                <div><strong>Canonical:</strong> <span class="text-gray-600 break-all">{html.escape(result.meta.canonical or 'N/A')}</span></div>
                <div><strong>Word Count:</strong> <span class="text-gray-600">{result.content.word_count} words (~{result.content.reading_time_minutes} min read)</span></div>
                <div><strong>Response Time:</strong> <span class="text-gray-600">{result.performance.response_time_ms} ms</span></div>
                <div><strong>Total Images:</strong> <span class="text-gray-600">{result.images.total_images} ({result.images.missing_alt} missing alt)</span></div>
            </div>
        </div>

        <!-- Issue List -->
        <div class="bg-white rounded-xl shadow-sm p-6 mb-6">
            <div class="flex justify-between items-center mb-4">
                <h2 class="text-lg font-bold text-gray-900">Audit Checks & Recommendations ({len(result.issues)})</h2>
                <div class="text-xs space-x-2">
                    <span class="px-2 py-1 rounded bg-emerald-100 text-emerald-800 font-semibold">{len(result.passed_issues)} Passed</span>
                    <span class="px-2 py-1 rounded bg-amber-100 text-amber-800 font-semibold">{len(result.warnings)} Warnings</span>
                    <span class="px-2 py-1 rounded bg-red-100 text-red-800 font-semibold">{len(result.errors)} Errors</span>
                </div>
            </div>
            {''.join(issues_html)}
        </div>

        <!-- Footer -->
        <footer class="text-center text-xs text-gray-500 py-4">
            Audited by <a href="https://seowebchecker.com/" target="_blank" class="text-indigo-600 font-semibold hover:underline">SEOWebChecker.com</a> — Free Online SEO Tools & Developer SDKs.
        </footer>
    </div>
</body>
</html>
"""
