"""Social graph (OpenGraph & Twitter Card) check engine for SEO audit."""

import re
from typing import Tuple, List
from seowebchecker_seoaudit.models import SocialInfo, Issue, Severity, Category

try:
    from bs4 import BeautifulSoup
except ImportError:
    BeautifulSoup = None


def extract_social(html: str) -> Tuple[SocialInfo, List[Issue]]:
    issues: List[Issue] = []
    social = SocialInfo()

    if BeautifulSoup:
        soup = BeautifulSoup(html, "html.parser")
        for tag in soup.find_all("meta"):
            prop = (tag.get("property") or "").lower().strip()
            name = (tag.get("name") or "").lower().strip()
            content = (tag.get("content") or "").strip()

            # OpenGraph
            if prop == "og:title":
                social.og_title = content
            elif prop == "og:description":
                social.og_description = content
            elif prop == "og:image":
                social.og_image = content
            elif prop == "og:url":
                social.og_url = content
            elif prop == "og:type":
                social.og_type = content

            # Twitter Card
            if name == "twitter:card":
                social.twitter_card = content
            elif name == "twitter:title":
                social.twitter_title = content
            elif name == "twitter:description":
                social.twitter_description = content
            elif name == "twitter:image":
                social.twitter_image = content
    else:
        # Regex fallback
        def find_meta(attr_type: str, key: str) -> str:
            p = re.compile(rf'<meta[^>]*{attr_type}=["\']({key})["\'][^>]*content=["\']([^"\']*)["\']', re.IGNORECASE)
            m = p.search(html)
            if not m:
                p2 = re.compile(rf'<meta[^>]*content=["\']([^"\']*)["\'][^>]*{attr_type}=["\']({key})["\']', re.IGNORECASE)
                m2 = p2.search(html)
                return m2.group(1).strip() if m2 else ""
            return m.group(2).strip()

        social.og_title = find_meta("property", "og:title") or None
        social.og_description = find_meta("property", "og:description") or None
        social.og_image = find_meta("property", "og:image") or None
        social.og_url = find_meta("property", "og:url") or None
        social.og_type = find_meta("property", "og:type") or None

        social.twitter_card = find_meta("name", "twitter:card") or None
        social.twitter_title = find_meta("name", "twitter:title") or None
        social.twitter_description = find_meta("name", "twitter:description") or None
        social.twitter_image = find_meta("name", "twitter:image") or None

    # OpenGraph checks
    missing_og = []
    if not social.og_title:
        missing_og.append("og:title")
    if not social.og_description:
        missing_og.append("og:description")
    if not social.og_image:
        missing_og.append("og:image")
    if not social.og_url:
        missing_og.append("og:url")

    if len(missing_og) == 4:
        issues.append(Issue(
            id="social-og-missing-all",
            category=Category.SOCIAL.value,
            severity=Severity.WARNING,
            title="Missing All OpenGraph Tags",
            message="No OpenGraph tags (og:title, og:description, og:image, og:url) found.",
            recommendation="Add OpenGraph meta tags so social shares on Facebook, LinkedIn, Slack, etc., look engaging.",
            impact_score=6,
        ))
    elif len(missing_og) > 0:
        issues.append(Issue(
            id="social-og-incomplete",
            category=Category.SOCIAL.value,
            severity=Severity.WARNING,
            title=f"Incomplete OpenGraph Tags (Missing {', '.join(missing_og)})",
            message=f"The following essential OpenGraph properties are missing: {', '.join(missing_og)}.",
            recommendation=f"Add {', '.join(missing_og)} to ensure rich previews across social platforms.",
            impact_score=3,
        ))
    else:
        issues.append(Issue(
            id="social-og-complete",
            category=Category.SOCIAL.value,
            severity=Severity.PASS,
            title="Complete OpenGraph Tags",
            message="All core OpenGraph tags (title, description, image, url) are present.",
            recommendation="OpenGraph tags are properly implemented.",
            impact_score=0,
        ))

    # Twitter card checks
    if not social.twitter_card:
        issues.append(Issue(
            id="social-twitter-missing",
            category=Category.SOCIAL.value,
            severity=Severity.NOTICE,
            title="Missing Twitter Card Meta Tag",
            message="The twitter:card meta tag was not detected.",
            recommendation="Add <meta name='twitter:card' content='summary_large_image'> for rich Twitter/X snippets.",
            impact_score=2,
        ))
    else:
        issues.append(Issue(
            id="social-twitter-present",
            category=Category.SOCIAL.value,
            severity=Severity.PASS,
            title="Twitter Card Configured",
            message=f"Twitter card type set to '{social.twitter_card}'.",
            recommendation="Twitter sharing card is active.",
            impact_score=0,
        ))

    return social, issues
