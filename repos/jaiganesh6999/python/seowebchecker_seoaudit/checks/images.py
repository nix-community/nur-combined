"""Images check engine for SEO audit."""

import re
from typing import Tuple, List, Dict, Any
from seowebchecker_seoaudit.models import ImagesInfo, Issue, Severity, Category

try:
    from bs4 import BeautifulSoup
except ImportError:
    BeautifulSoup = None

MODERN_FORMATS = {"webp", "avif", "svg"}


def extract_images(html: str) -> Tuple[ImagesInfo, List[Issue]]:
    issues: List[Issue] = []
    images = ImagesInfo()

    extracted_imgs = []

    if BeautifulSoup:
        soup = BeautifulSoup(html, "html.parser")
        for img in soup.find_all("img"):
            src = (img.get("src") or img.get("data-src") or "").strip()
            alt = img.get("alt")
            extracted_imgs.append((src, alt))
    else:
        pattern = re.compile(r'<img\s+([^>]*?)>', re.IGNORECASE)
        for match in pattern.finditer(html):
            attrs = match.group(1)
            m_src = re.search(r'(?:data-)?src=["\']([^"\']*)["\']', attrs, re.IGNORECASE)
            src = m_src.group(1).strip() if m_src else ""

            m_alt = re.search(r'alt=["\']([^"\']*)["\']', attrs, re.IGNORECASE)
            if m_alt is not None:
                alt = m_alt.group(1)
            else:
                alt = None

            extracted_imgs.append((src, alt))

    images.total_images = len(extracted_imgs)
    formats: Dict[str, int] = {}

    for src, alt in extracted_imgs:
        # Check format
        ext = ""
        clean_src = src.split("?")[0].lower()
        if "." in clean_src:
            ext = clean_src.rsplit(".", 1)[-1]
        elif clean_src.startswith("data:image/"):
            ext = clean_src.split(";")[0].replace("data:image/", "")

        if ext:
            formats[ext] = formats.get(ext, 0) + 1
            if ext in MODERN_FORMATS:
                images.modern_formats_count += 1

        if alt is None:
            images.missing_alt += 1
        elif alt.strip() == "":
            images.empty_alt += 1

        if len(images.sample_images) < 10 and src:
            images.sample_images.append({
                "src": src[:100],
                "alt": alt if alt is not None else "[MISSING]",
                "format": ext or "unknown",
            })

    images.formats_breakdown = formats

    # Rule checks
    if images.total_images == 0:
        issues.append(Issue(
            id="images-none",
            category=Category.IMAGES.value,
            severity=Severity.NOTICE,
            title="No Images Found",
            message="No <img> tags were detected on this page.",
            recommendation="Consider adding relevant imagery or diagrams to enhance user engagement and visual appeal.",
            impact_score=1,
        ))
    else:
        if images.missing_alt > 0:
            issues.append(Issue(
                id="images-missing-alt",
                category=Category.IMAGES.value,
                severity=Severity.ERROR,
                title=f"{images.missing_alt} Image(s) Missing 'alt' Attribute",
                message=f"{images.missing_alt} out of {images.total_images} images lack the 'alt' attribute entirely.",
                recommendation="Add descriptive 'alt' text to all images for SEO image indexing and screen reader accessibility.",
                impact_score=6,
            ))
        else:
            issues.append(Issue(
                id="images-all-alt-present",
                category=Category.IMAGES.value,
                severity=Severity.PASS,
                title="All Images Have 'alt' Attributes",
                message=f"All {images.total_images} images have 'alt' attributes present.",
                recommendation="Great accessibility and image SEO practice.",
                impact_score=0,
            ))

        # Modern format check
        if images.modern_formats_count == 0 and images.total_images > 2:
            issues.append(Issue(
                id="images-legacy-formats",
                category=Category.IMAGES.value,
                severity=Severity.WARNING,
                title="No Modern Image Formats Used",
                message="Page relies entirely on legacy image formats (JPEG, PNG, GIF).",
                recommendation="Convert images to next-gen formats like WebP or AVIF to reduce page weight by 30-70%.",
                impact_score=3,
            ))
        elif images.modern_formats_count > 0:
            issues.append(Issue(
                id="images-modern-formats",
                category=Category.IMAGES.value,
                severity=Severity.PASS,
                title="Next-Gen Image Formats in Use",
                message=f"{images.modern_formats_count}/{images.total_images} images use modern formats (WebP/AVIF/SVG).",
                recommendation="Continue using efficient next-gen image compression.",
                impact_score=0,
            ))

    return images, issues
