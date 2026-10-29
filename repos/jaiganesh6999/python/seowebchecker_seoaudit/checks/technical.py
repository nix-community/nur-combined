"""Technical SEO and Security headers check engine."""

from typing import Tuple, List, Dict, Optional
from seowebchecker_seoaudit.models import TechnicalInfo, Issue, Severity, Category


def extract_technical(
    url: str,
    headers: Dict[str, str],
    robots_found: Optional[bool] = None,
    sitemap_found: Optional[bool] = None
) -> Tuple[TechnicalInfo, List[Issue]]:
    issues: List[Issue] = []
    tech = TechnicalInfo()

    tech.headers = {k.lower(): v for k, v in headers.items()}
    tech.is_https = url.lower().startswith("https://")

    # Header lookup
    hsts = tech.headers.get("strict-transport-security")
    tech.hsts_enabled = bool(hsts)

    tech.x_content_type_options = tech.headers.get("x-content-type-options")
    tech.x_frame_options = tech.headers.get("x-frame-options")
    tech.content_security_policy = bool(tech.headers.get("content-security-policy"))

    tech.robots_txt_found = robots_found
    tech.sitemap_found = sitemap_found

    # Rule checks
    # HTTPS
    if not tech.is_https:
        issues.append(Issue(
            id="tech-not-https",
            category=Category.TECHNICAL.value,
            severity=Severity.ERROR,
            title="Insecure HTTP Protocol",
            message=f"The site URL ({url}) uses insecure HTTP instead of HTTPS.",
            recommendation="Install an SSL/TLS certificate and enforce 301 redirects from HTTP to HTTPS for user security and Google search ranking factor.",
            impact_score=10,
        ))
    else:
        issues.append(Issue(
            id="tech-https-active",
            category=Category.TECHNICAL.value,
            severity=Severity.PASS,
            title="Secure HTTPS Active",
            message="Connection is secured over HTTPS with SSL/TLS encryption.",
            recommendation="Maintain valid SSL certificates and automatic renewal.",
            impact_score=0,
        ))

    # HSTS
    if tech.is_https:
        if not tech.hsts_enabled:
            issues.append(Issue(
                id="tech-hsts-missing",
                category=Category.TECHNICAL.value,
                severity=Severity.WARNING,
                title="Missing HSTS Header",
                message="Strict-Transport-Security (HSTS) response header is not enabled.",
                recommendation="Add 'Strict-Transport-Security: max-age=31536000; includeSubDomains; preload' to enforce secure connections.",
                impact_score=3,
            ))
        else:
            issues.append(Issue(
                id="tech-hsts-present",
                category=Category.TECHNICAL.value,
                severity=Severity.PASS,
                title="HSTS Security Enabled",
                message=f"Strict-Transport-Security header present: {hsts}",
                recommendation="Good security posture.",
                impact_score=0,
            ))

    # X-Content-Type-Options
    if not tech.x_content_type_options or "nosniff" not in tech.x_content_type_options.lower():
        issues.append(Issue(
            id="tech-nosniff-missing",
            category=Category.TECHNICAL.value,
            severity=Severity.NOTICE,
            title="Missing 'X-Content-Type-Options: nosniff'",
            message="The X-Content-Type-Options header is absent or does not specify nosniff.",
            recommendation="Add 'X-Content-Type-Options: nosniff' to prevent MIME-sniffing exploits.",
            impact_score=2,
        ))
    else:
        issues.append(Issue(
            id="tech-nosniff-present",
            category=Category.TECHNICAL.value,
            severity=Severity.PASS,
            title="MIME-Sniffing Protection Active",
            message="X-Content-Type-Options: nosniff is set.",
            recommendation="Security header configured properly.",
            impact_score=0,
        ))

    # X-Frame-Options
    if not tech.x_frame_options and not tech.content_security_policy:
        issues.append(Issue(
            id="tech-clickjack-unprotected",
            category=Category.TECHNICAL.value,
            severity=Severity.NOTICE,
            title="Missing Clickjacking Defense",
            message="Neither X-Frame-Options nor CSP frame-ancestors header was detected.",
            recommendation="Add 'X-Frame-Options: SAMEORIGIN' to protect the site from clickjacking attacks.",
            impact_score=2,
        ))
    else:
        issues.append(Issue(
            id="tech-clickjack-protected",
            category=Category.TECHNICAL.value,
            severity=Severity.PASS,
            title="Clickjacking Protection Active",
            message=f"Frame protection configured: {tech.x_frame_options or 'CSP frame-ancestors'}",
            recommendation="Frame embedding protection active.",
            impact_score=0,
        ))

    # Robots.txt
    if robots_found is True:
        issues.append(Issue(
            id="tech-robots-txt-found",
            category=Category.TECHNICAL.value,
            severity=Severity.PASS,
            title="robots.txt File Detected",
            message="Found valid robots.txt file at /robots.txt.",
            recommendation="Ensure crawl directives allow search engine bots to crawl valuable sections.",
            impact_score=0,
        ))
    elif robots_found is False:
        issues.append(Issue(
            id="tech-robots-txt-missing",
            category=Category.TECHNICAL.value,
            severity=Severity.WARNING,
            title="Missing robots.txt File",
            message="No robots.txt file was found at /robots.txt.",
            recommendation="Create a robots.txt file in the root directory to direct crawler traffic and specify sitemap location.",
            impact_score=4,
        ))

    # Sitemap.xml
    if sitemap_found is True:
        issues.append(Issue(
            id="tech-sitemap-found",
            category=Category.TECHNICAL.value,
            severity=Severity.PASS,
            title="XML Sitemap Detected",
            message="Found XML Sitemap at /sitemap.xml or referenced in robots.txt.",
            recommendation="Keep XML sitemap dynamically updated with latest URLs.",
            impact_score=0,
        ))
    elif sitemap_found is False:
        issues.append(Issue(
            id="tech-sitemap-missing",
            category=Category.TECHNICAL.value,
            severity=Severity.WARNING,
            title="Missing XML Sitemap",
            message="Could not find /sitemap.xml.",
            recommendation="Generate an XML sitemap and submit it to Google Search Console and Bing Webmaster Tools.",
            impact_score=4,
        ))

    return tech, issues
