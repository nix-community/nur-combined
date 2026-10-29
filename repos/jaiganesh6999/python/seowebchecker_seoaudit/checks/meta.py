"""Meta tags check engine for SEO audit."""

import re
from typing import Tuple, List, Optional
from seowebchecker_seoaudit.models import MetaInfo, Issue, Severity, Category

try:
    from bs4 import BeautifulSoup
except ImportError:
    BeautifulSoup = None  # Fallback to regex parser if beautifulsoup4 is not available


def extract_meta(html: str) -> Tuple[MetaInfo, List[Issue]]:
    issues: List[Issue] = []
    meta = MetaInfo()

    if BeautifulSoup:
        soup = BeautifulSoup(html, "html.parser")

        # Language
        html_tag = soup.find("html")
        if html_tag and html_tag.get("lang"):
            meta.language = html_tag.get("lang").strip()

        # Title
        title_tag = soup.find("title")
        if title_tag and title_tag.string:
            meta.title = title_tag.string.strip()
            meta.title_length = len(meta.title)

        # Meta tags
        for tag in soup.find_all("meta"):
            name = (tag.get("name") or tag.get("http-equiv") or "").lower().strip()
            content = (tag.get("content") or "").strip()

            if name == "description":
                meta.description = content
                meta.description_length = len(content)
            elif name == "robots":
                meta.robots = content
            elif name == "viewport":
                meta.viewport = content

            if tag.get("charset"):
                meta.charset = tag.get("charset").strip()

        # Canonical
        canonical_tag = soup.find("link", rel=lambda r: r and "canonical" in r)
        if canonical_tag and canonical_tag.get("href"):
            meta.canonical = canonical_tag.get("href").strip()

        # Favicon
        icon_tag = soup.find("link", rel=lambda r: r and any(x in r for x in ["icon", "shortcut icon"]))
        if icon_tag and icon_tag.get("href"):
            meta.favicon = icon_tag.get("href").strip()
    else:
        # Regex fallback parser
        # Lang
        m_lang = re.search(r'<html[^>]*lang=["\']([^"\']+)["\']', html, re.IGNORECASE)
        if m_lang:
            meta.language = m_lang.group(1).strip()

        # Title
        m_title = re.search(r'<title[^>]*>(.*?)</title>', html, re.IGNORECASE | re.DOTALL)
        if m_title:
            meta.title = re.sub(r'\s+', ' ', m_title.group(1)).strip()
            meta.title_length = len(meta.title)

        # Description
        m_desc = re.search(r'<meta[^>]*name=["\']description["\'][^>]*content=["\']([^"\']*)["\']', html, re.IGNORECASE)
        if not m_desc:
            m_desc = re.search(r'<meta[^>]*content=["\']([^"\']*)["\'][^>]*name=["\']description["\']', html, re.IGNORECASE)
        if m_desc:
            meta.description = m_desc.group(1).strip()
            meta.description_length = len(meta.description)

        # Robots
        m_robots = re.search(r'<meta[^>]*name=["\']robots["\'][^>]*content=["\']([^"\']*)["\']', html, re.IGNORECASE)
        if m_robots:
            meta.robots = m_robots.group(1).strip()

        # Viewport
        m_vp = re.search(r'<meta[^>]*name=["\']viewport["\'][^>]*content=["\']([^"\']*)["\']', html, re.IGNORECASE)
        if m_vp:
            meta.viewport = m_vp.group(1).strip()

        # Charset
        m_cs = re.search(r'<meta[^>]*charset=["\']([^"\']+)["\']', html, re.IGNORECASE)
        if m_cs:
            meta.charset = m_cs.group(1).strip()

        # Canonical
        m_canon = re.search(r'<link[^>]*rel=["\']canonical["\'][^>]*href=["\']([^"\']+)["\']', html, re.IGNORECASE)
        if m_canon:
            meta.canonical = m_canon.group(1).strip()

    # Rule checks
    # Title Check
    if not meta.title:
        issues.append(Issue(
            id="meta-title-missing",
            category=Category.META.value,
            severity=Severity.ERROR,
            title="Missing Page Title",
            message="The <title> tag is missing or empty.",
            recommendation="Add a descriptive <title> tag between 30 and 60 characters for maximum search visibility.",
            impact_score=10,
        ))
    elif meta.title_length < 30:
        issues.append(Issue(
            id="meta-title-short",
            category=Category.META.value,
            severity=Severity.WARNING,
            title="Page Title Too Short",
            message=f"Page title is {meta.title_length} characters ('{meta.title}').",
            recommendation="Expand page title to at least 30 characters (optimal: 30-60 characters).",
            impact_score=4,
        ))
    elif meta.title_length > 65:
        issues.append(Issue(
            id="meta-title-long",
            category=Category.META.value,
            severity=Severity.WARNING,
            title="Page Title Too Long",
            message=f"Page title is {meta.title_length} characters. Search engines typically truncate titles over 60 characters.",
            recommendation="Shorten page title to under 60 characters to prevent truncation in search result snippets.",
            impact_score=4,
        ))
    else:
        issues.append(Issue(
            id="meta-title-optimal",
            category=Category.META.value,
            severity=Severity.PASS,
            title="Optimal Page Title Length",
            message=f"Page title is {meta.title_length} characters: '{meta.title}'.",
            recommendation="Keep this concise and descriptive title tag.",
            impact_score=0,
        ))

    # Meta Description Check
    if not meta.description:
        issues.append(Issue(
            id="meta-desc-missing",
            category=Category.META.value,
            severity=Severity.ERROR,
            title="Missing Meta Description",
            message="No <meta name='description'> tag found on the page.",
            recommendation="Add a compelling meta description between 120 and 160 characters to improve click-through rates.",
            impact_score=8,
        ))
    elif meta.description_length < 70:
        issues.append(Issue(
            id="meta-desc-short",
            category=Category.META.value,
            severity=Severity.WARNING,
            title="Meta Description Too Short",
            message=f"Meta description is only {meta.description_length} characters.",
            recommendation="Expand meta description to at least 120 characters to provide sufficient context in SERPs.",
            impact_score=3,
        ))
    elif meta.description_length > 165:
        issues.append(Issue(
            id="meta-desc-long",
            category=Category.META.value,
            severity=Severity.WARNING,
            title="Meta Description Too Long",
            message=f"Meta description is {meta.description_length} characters (optimal: 120-160 characters).",
            recommendation="Trim meta description to under 160 characters to avoid snippet truncation.",
            impact_score=2,
        ))
    else:
        issues.append(Issue(
            id="meta-desc-optimal",
            category=Category.META.value,
            severity=Severity.PASS,
            title="Optimal Meta Description Length",
            message=f"Meta description length is {meta.description_length} characters.",
            recommendation="Well crafted meta description.",
            impact_score=0,
        ))

    # Canonical Check
    if not meta.canonical:
        issues.append(Issue(
            id="meta-canonical-missing",
            category=Category.META.value,
            severity=Severity.WARNING,
            title="Missing Canonical Tag",
            message="No <link rel='canonical'> specified.",
            recommendation="Add a canonical tag to prevent duplicate content indexing issues across query parameters and protocols.",
            impact_score=5,
        ))
    else:
        issues.append(Issue(
            id="meta-canonical-present",
            category=Category.META.value,
            severity=Severity.PASS,
            title="Canonical Tag Configured",
            message=f"Canonical URL is set to {meta.canonical}",
            recommendation="Ensure the canonical URL points to the authoritative version of this page.",
            impact_score=0,
        ))

    # Viewport Check (Mobile Friendliness)
    if not meta.viewport:
        issues.append(Issue(
            id="meta-viewport-missing",
            category=Category.META.value,
            severity=Severity.ERROR,
            title="Missing Viewport Tag (Mobile Responsive)",
            message="The mobile viewport meta tag was not detected.",
            recommendation="Add <meta name='viewport' content='width=device-width, initial-scale=1.0'> for proper mobile rendering.",
            impact_score=8,
        ))
    else:
        issues.append(Issue(
            id="meta-viewport-present",
            category=Category.META.value,
            severity=Severity.PASS,
            title="Mobile Viewport Configured",
            message=f"Viewport meta tag configured: {meta.viewport}",
            recommendation="Mobile responsive viewport is set.",
            impact_score=0,
        ))

    # Robots tag check
    if meta.robots and "noindex" in meta.robots.lower():
        issues.append(Issue(
            id="meta-robots-noindex",
            category=Category.META.value,
            severity=Severity.WARNING,
            title="Page Has 'noindex' Directive",
            message=f"Robots meta tag contains noindex: '{meta.robots}'. Search engines will not index this page.",
            recommendation="Remove 'noindex' if you intend for this page to appear in public search engines.",
            impact_score=6,
        ))

    # Language check
    if not meta.language:
        issues.append(Issue(
            id="meta-lang-missing",
            category=Category.META.value,
            severity=Severity.NOTICE,
            title="Missing <html> lang Attribute",
            message="The <html> element does not specify a lang attribute.",
            recommendation="Add a lang attribute (e.g., <html lang='en'>) to help search engines understand page language.",
            impact_score=2,
        ))
    else:
        issues.append(Issue(
            id="meta-lang-present",
            category=Category.META.value,
            severity=Severity.PASS,
            title="HTML Language Specified",
            message=f"Page language is set to '{meta.language}'.",
            recommendation="Good internationalization practice.",
            impact_score=0,
        ))

    return meta, issues
