"""Links check engine for SEO audit."""

import re
from urllib.parse import urlparse
from typing import Tuple, List, Dict, Any
from seowebchecker_seoaudit.models import LinksInfo, Issue, Severity, Category

try:
    from bs4 import BeautifulSoup
except ImportError:
    BeautifulSoup = None

GENERIC_ANCHORS = {
    "click here", "read more", "learn more", "here", "more", "link", "view more",
    "check here", "this link", "continue reading", "get started", "website"
}


def extract_links(html: str, base_url: str = "") -> Tuple[LinksInfo, List[Issue]]:
    issues: List[Issue] = []
    links = LinksInfo()

    base_domain = ""
    if base_url:
        try:
            base_domain = urlparse(base_url).netloc.lower()
        except Exception:
            pass

    extracted_links = []

    if BeautifulSoup:
        soup = BeautifulSoup(html, "html.parser")
        for a in soup.find_all("a"):
            href = (a.get("href") or "").strip()
            text = a.get_text().strip()
            rel = (a.get("rel") or [])
            if isinstance(rel, str):
                rel = rel.split()
            target = (a.get("target") or "").strip().lower()
            extracted_links.append((href, text, rel, target))
    else:
        pattern = re.compile(r'<a\s+([^>]*?)>(.*?)</a>', re.IGNORECASE | re.DOTALL)
        for match in pattern.finditer(html):
            attrs_str = match.group(1)
            raw_text = re.sub(r'<[^>]+>', '', match.group(2)).strip()

            m_href = re.search(r'href=["\']([^"\']*)["\']', attrs_str, re.IGNORECASE)
            href = m_href.group(1).strip() if m_href else ""

            m_rel = re.search(r'rel=["\']([^"\']*)["\']', attrs_str, re.IGNORECASE)
            rel_str = m_rel.group(1) if m_rel else ""
            rel = rel_str.split()

            m_target = re.search(r'target=["\']([^"\']*)["\']', attrs_str, re.IGNORECASE)
            target = m_target.group(1).strip().lower() if m_target else ""

            extracted_links.append((href, raw_text, rel, target))

    links.total_links = len(extracted_links)
    target_blank_insecure = 0

    for href, text, rel, target in extracted_links:
        # Ignore mailto, tel, javascript, anchors
        if not href or href.startswith(("#", "javascript:", "mailto:", "tel:")):
            if not href or href.startswith("#"):
                links.internal_links += 1
            continue

        is_external = False
        if href.startswith(("http://", "https://")):
            parsed = urlparse(href)
            link_domain = parsed.netloc.lower()
            if base_domain and link_domain != base_domain and not link_domain.endswith("." + base_domain):
                is_external = True
            elif not base_domain:
                is_external = True
        else:
            is_external = False

        if is_external:
            links.external_links += 1
        else:
            links.internal_links += 1

        is_nofollow = any(r.lower() == "nofollow" for r in rel)
        if is_nofollow:
            links.nofollow_links += 1

        if not text:
            links.empty_anchors += 1

        if text.lower() in GENERIC_ANCHORS:
            links.generic_anchors += 1

        if target == "_blank":
            has_opener = any(r.lower() in ["noopener", "noreferrer"] for r in rel)
            if not has_opener:
                target_blank_insecure += 1

        if len(links.sample_links) < 15 and href:
            links.sample_links.append({
                "href": href[:120],
                "text": text[:60] if text else "[EMPTY]",
                "external": is_external,
                "nofollow": is_nofollow,
            })

    # Rule checks
    if links.total_links == 0:
        issues.append(Issue(
            id="links-none",
            category=Category.LINKS.value,
            severity=Severity.WARNING,
            title="No Hyperlinks Detected",
            message="No <a> links were found on the page.",
            recommendation="Add internal and contextual links to facilitate navigation and search bot crawling.",
            impact_score=4,
        ))
    else:
        issues.append(Issue(
            id="links-present",
            category=Category.LINKS.value,
            severity=Severity.PASS,
            title="Hyperlinks Detected",
            message=f"Found {links.total_links} total links ({links.internal_links} internal, {links.external_links} external).",
            recommendation="Good linking structure.",
            impact_score=0,
        ))

    if links.empty_anchors > 0:
        issues.append(Issue(
            id="links-empty-anchors",
            category=Category.LINKS.value,
            severity=Severity.WARNING,
            title=f"Empty Anchor Text on {links.empty_anchors} Links",
            message=f"{links.empty_anchors} links have no descriptive anchor text or accessible labels.",
            recommendation="Add descriptive text, aria-label, or title attributes to empty link elements.",
            impact_score=3,
        ))

    if links.generic_anchors > 0:
        issues.append(Issue(
            id="links-generic-anchors",
            category=Category.LINKS.value,
            severity=Severity.NOTICE,
            title=f"Non-descriptive Anchor Texts ({links.generic_anchors})",
            message=f"Detected {links.generic_anchors} generic link texts like 'click here' or 'read more'.",
            recommendation="Replace generic phrases with keyword-rich anchor texts describing the target destination.",
            impact_score=2,
        ))

    if target_blank_insecure > 0:
        issues.append(Issue(
            id="links-target-blank-unsafe",
            category=Category.LINKS.value,
            severity=Severity.WARNING,
            title=f"Unsafe target='_blank' Links ({target_blank_insecure})",
            message=f"Found {target_blank_insecure} links opening in new tab without rel='noopener' or rel='noreferrer'.",
            recommendation="Add rel='noopener noreferrer' to external target='_blank' links to prevent tab-nabbing vulnerabilities.",
            impact_score=3,
        ))

    return links, issues
