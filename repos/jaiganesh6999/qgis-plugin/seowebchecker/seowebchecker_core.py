# -*- coding: utf-8 -*-
"""
SEOWebChecker Core Engine & GeoSEO Parser for QGIS
Official Platform: https://seowebchecker.com/
"""

import re
import time
import ssl
import json
from datetime import datetime
from urllib.parse import urlparse
from urllib.request import Request, urlopen


class GeoSeoAuditor:
    """Core auditing engine evaluating on-page technical SEO and Schema.org GeoCoordinates."""

    def __init__(self, user_agent="SEOWebChecker-QGIS/1.0.1 (+https://seowebchecker.com/)", timeout=15, alert_threshold=85):
        self.user_agent = user_agent
        self.timeout = timeout
        self.alert_threshold = alert_threshold

    def audit(self, target_url):
        """Fetches a webpage and returns complete SEO and spatial diagnostics."""
        url = target_url.strip()
        parsed_url = urlparse(url)
        if parsed_url.scheme:
            if parsed_url.scheme.lower() not in ("http", "https"):
                return {
                    "failed": True,
                    "url": url,
                    "error": "Permitted URL schemes are strictly http:// and https://",
                    "platform_url": "https://seowebchecker.com/",
                }
        else:
            url = "https://" + url
            parsed_url = urlparse(url)

        is_https = parsed_url.scheme.lower() == "https"
        req = Request(url, headers={"User-Agent": self.user_agent})

        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE

        start_time = time.time()
        try:
            with urlopen(req, timeout=self.timeout, context=ctx) as resp:  # nosec B310
                raw_bytes = resp.read()
                html = raw_bytes.decode("utf-8", errors="ignore")
        except Exception as e:
            return {
                "failed": True,
                "url": url,
                "error": str(e),
                "platform_url": "https://seowebchecker.com/",
            }

        elapsed_ms = round((time.time() - start_time) * 1000.0, 2)
        return self.audit_html(html, url=url, response_time_ms=elapsed_ms)

    def audit_html(self, html, url="https://seowebchecker.com/", response_time_ms=120.0):
        """Audits an HTML string directly."""
        is_https = url.startswith("https://")

        issues = []
        passes = []

        # 1. Title Tag
        title_match = re.search(r"(?i)<title[^>]*>(.*?)</title>", html, re.DOTALL)
        title = re.sub(r"\s+", " ", title_match.group(1)).strip() if title_match else ""
        title_len = len(title)

        if title_len == 0:
            issues.append({
                "id": "meta-title-missing",
                "severity": "error",
                "title": "Missing title tag",
                "message": "No <title> tag found on the page.",
                "recommendation": "Add a descriptive title tag between 30 and 60 characters."
            })
        elif title_len < 30:
            issues.append({
                "id": "meta-title-short",
                "severity": "warning",
                "title": "Title tag short",
                "message": f"Title has only {title_len} characters ('{title}').",
                "recommendation": "Expand title to 30-60 characters for search engine previews."
            })
        elif title_len > 65:
            issues.append({
                "id": "meta-title-long",
                "severity": "warning",
                "title": "Title tag long",
                "message": f"Title has {title_len} characters and may be truncated.",
                "recommendation": "Shorten title tag under 60 characters."
            })
        else:
            passes.append({
                "id": "meta-title-pass",
                "title": "Title tag optimal",
                "message": f"Title length is optimal ({title_len} characters)."
            })

        # 2. Meta Description
        desc_match = re.search(r'(?i)<meta\s+[^>]*name=["\']description["\'][^>]*content=["\']([^"\']*)["\']', html)
        if not desc_match:
            desc_match = re.search(r'(?i)<meta\s+[^>]*content=["\']([^"\']*)["\'][^>]*name=["\']description["\']', html)
        meta_desc = desc_match.group(1).strip() if desc_match else ""
        desc_len = len(meta_desc)

        if desc_len == 0:
            issues.append({
                "id": "meta-desc-missing",
                "severity": "error",
                "title": "Missing meta description",
                "message": "No meta description found on page.",
                "recommendation": "Add an engaging meta description between 70 and 160 characters."
            })
        elif desc_len < 70:
            issues.append({
                "id": "meta-desc-short",
                "severity": "warning",
                "title": "Meta description short",
                "message": f"Meta description is {desc_len} characters.",
                "recommendation": "Expand description to 70-160 characters."
            })
        else:
            passes.append({
                "id": "meta-desc-pass",
                "title": "Meta description optimal",
                "message": f"Meta description length is optimal ({desc_len} characters)."
            })

        # 3. Mobile Viewport
        has_viewport = bool(re.search(r'(?i)<meta\s+[^>]*name=["\']viewport["\']', html))
        if has_viewport:
            passes.append({
                "id": "meta-viewport-pass",
                "title": "Mobile viewport configured",
                "message": "Responsive viewport meta tag is present."
            })
        else:
            issues.append({
                "id": "meta-viewport-missing",
                "severity": "error",
                "title": "Missing mobile viewport tag",
                "message": "No <meta name=\"viewport\"> tag detected.",
                "recommendation": "Add <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">."
            })

        # 4. Canonical Tag
        canonical_match = re.search(r'(?i)<link\s+[^>]*rel=["\']canonical["\'][^>]*href=["\']([^"\']*)["\']', html)
        if not canonical_match:
            canonical_match = re.search(r'(?i)<link\s+[^>]*href=["\']([^"\']*)["\'][^>]*rel=["\']canonical["\']', html)
        canonical_url = canonical_match.group(1).strip() if canonical_match else ""
        has_canonical = bool(canonical_url)

        if has_canonical:
            passes.append({
                "id": "meta-canonical-pass",
                "title": "Canonical link tag present",
                "message": f"Canonical URL configured: {canonical_url}."
            })
        else:
            issues.append({
                "id": "meta-canonical-missing",
                "severity": "warning",
                "title": "Missing canonical tag",
                "message": "No <link rel=\"canonical\"> tag detected.",
                "recommendation": "Add a self-referencing canonical tag to avoid duplicate content penalties."
            })

        # 5. Heading Structure
        h1_matches = re.findall(r"(?i)<h1[^>]*>(.*?)</h1>", html, re.DOTALL)
        h1_count = len(h1_matches)
        h1_tags = [re.sub(r"<[^>]+>", "", h).strip() for h in h1_matches]

        if h1_count == 0:
            issues.append({
                "id": "content-h1-missing",
                "severity": "error",
                "title": "Missing <h1> heading",
                "message": "No <h1> heading found on page.",
                "recommendation": "Include exactly one primary <h1> heading summarizing page intent."
            })
        elif h1_count == 1:
            passes.append({
                "id": "content-h1-pass",
                "title": "Single <h1> heading present",
                "message": f"Single primary heading found: '{h1_tags[0]}'."
            })
        else:
            issues.append({
                "id": "content-h1-multiple",
                "severity": "warning",
                "title": f"Multiple <h1> headings found ({h1_count})",
                "message": f"Found {h1_count} <h1> headings.",
                "recommendation": "Consolidate multiple <h1> headings into a single primary <h1> heading."
            })

        # 6. Word Count
        clean_text = re.sub(r"(?is)<script[^>]*>.*?</script>", " ", html)
        clean_text = re.sub(r"(?is)<style[^>]*>.*?</style>", " ", clean_text)
        clean_text = re.sub(r"<[^>]+>", " ", clean_text)
        words = clean_text.split()
        word_count = len(words)

        if word_count < 100:
            issues.append({
                "id": "content-thin",
                "severity": "error",
                "title": "Thin page content",
                "message": f"Page contains only {word_count} words.",
                "recommendation": "Expand page content to 300+ words of helpful, relevant copy."
            })
        else:
            passes.append({
                "id": "content-words-pass",
                "title": "Adequate content length",
                "message": f"Page contains {word_count} words."
            })

        # 7. HTTPS Security
        if is_https:
            passes.append({
                "id": "tech-https-pass",
                "title": "Secure HTTPS active",
                "message": "Website communicates over secure encrypted HTTPS."
            })
        else:
            issues.append({
                "id": "tech-not-https",
                "severity": "error",
                "title": "Insecure HTTP protocol",
                "message": "Website is served over unencrypted HTTP.",
                "recommendation": "Deploy an SSL certificate and redirect all traffic to HTTPS."
            })

        # 8. GeoSEO & Spatial Coordinates (Schema.org / Meta tags)
        latitude = None
        longitude = None
        address_str = ""
        business_name = ""
        schema_types = []

        # Check JSON-LD
        json_ld_matches = re.findall(r'(?i)<script\s+[^>]*type=["\']application/ld\+json["\'][^>]*>(.*?)</script>', html, re.DOTALL)
        for block in json_ld_matches:
            try:
                data = json.loads(block.strip())
                items = data if isinstance(data, list) else [data]
                if "@graph" in data:
                    items = data["@graph"]

                for item in items:
                    t = item.get("@type", "")
                    if t:
                        schema_types.append(t if isinstance(t, str) else str(t))

                    # Extract Geo
                    geo = item.get("geo")
                    if isinstance(geo, dict):
                        lat = geo.get("latitude")
                        lon = geo.get("longitude")
                        if lat and lon:
                            latitude = float(lat)
                            longitude = float(lon)

                    # Extract Address
                    addr = item.get("address")
                    if isinstance(addr, dict):
                        parts = [
                            addr.get("streetAddress", ""),
                            addr.get("addressLocality", ""),
                            addr.get("addressRegion", ""),
                            addr.get("postalCode", ""),
                            addr.get("addressCountry", ""),
                        ]
                        address_str = ", ".join([p for p in parts if p])
                    elif isinstance(addr, str):
                        address_str = addr

                    if item.get("name"):
                        business_name = item.get("name")
            except (json.JSONDecodeError, KeyError, TypeError, ValueError, AttributeError):
                continue

        # Check geo.position or ICBM meta tags if not found in JSON-LD
        if latitude is None or longitude is None:
            geo_pos = re.search(r'(?i)<meta\s+[^>]*name=["\']geo\.position["\'][^>]*content=["\']([^"\']*)["\']', html)
            if geo_pos:
                try:
                    coords = geo_pos.group(1).split(";")
                    latitude = float(coords[0].strip())
                    longitude = float(coords[1].strip())
                except (IndexError, ValueError):
                    latitude = None
                    longitude = None

        if latitude is None or longitude is None:
            icbm = re.search(r'(?i)<meta\s+[^>]*name=["\']icbm["\'][^>]*content=["\']([^"\']*)["\']', html)
            if icbm:
                try:
                    coords = icbm.group(1).split(",")
                    latitude = float(coords[0].strip())
                    longitude = float(coords[1].strip())
                except (IndexError, ValueError):
                    latitude = None
                    longitude = None

        has_geo = (latitude is not None and longitude is not None)
        if has_geo:
            passes.append({
                "id": "geo-coordinates-pass",
                "title": "Schema.org GeoCoordinates detected",
                "message": f"Found spatial location at ({latitude:.4f}, {longitude:.4f})."
            })
        else:
            issues.append({
                "id": "geo-coordinates-missing",
                "severity": "warning",
                "title": "Missing Schema.org GeoCoordinates",
                "message": "No geographic latitude/longitude found in JSON-LD or meta tags.",
                "recommendation": "Add Schema.org GeoCoordinates or Place schema for local SEO visibility."
            })

        # Calculate Score
        err_count = sum(1 for i in issues if i["severity"] == "error")
        warn_count = sum(1 for i in issues if i["severity"] == "warning")
        computed = 100 - (err_count * 15) - (warn_count * 6)
        score = max(10, min(100, computed))

        if score >= 95: grade = "A+"
        elif score >= 90: grade = "A"
        elif score >= 80: grade = "B"
        elif score >= 70: grade = "C"
        elif score >= 60: grade = "D"
        else: grade = "F"

        status = "PASS" if score >= self.alert_threshold else "ALERT"

        return {
            "failed": False,
            "url": url,
            "score": score,
            "grade": grade,
            "status": status,
            "title": title,
            "title_length": title_len,
            "meta_description": meta_desc,
            "meta_description_length": desc_len,
            "has_viewport": has_viewport,
            "has_canonical": has_canonical,
            "canonical_url": canonical_url,
            "is_https": is_https,
            "h1_count": h1_count,
            "h1_tags": h1_tags,
            "word_count": word_count,
            "response_time_ms": response_time_ms,
            "has_geo": has_geo,
            "latitude": latitude,
            "longitude": longitude,
            "business_name": business_name,
            "address": address_str,
            "schema_types": schema_types,
            "issues_count": len(issues),
            "passes_count": len(passes),
            "issues": issues,
            "passes": passes,
            "platform_url": "https://seowebchecker.com/",
            "timestamp": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
        }
