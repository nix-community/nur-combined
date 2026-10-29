"""Data models for SEOWebChecker SEO Audit SDK."""

from __future__ import annotations
import json
from dataclasses import dataclass, field, asdict
from enum import Enum
from typing import Any, Dict, List, Optional


class Severity(str, Enum):
    ERROR = "error"
    WARNING = "warning"
    NOTICE = "notice"
    PASS = "pass"


class Category(str, Enum):
    META = "meta"
    CONTENT = "content"
    TECHNICAL = "technical"
    PERFORMANCE = "performance"
    SOCIAL = "social"
    LINKS = "links"
    IMAGES = "images"
    SCHEMA = "schema"


@dataclass
class Issue:
    id: str
    category: str
    severity: Severity
    title: str
    message: str
    recommendation: str
    impact_score: int = 5  # Deduction on failure (1-10)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "category": self.category,
            "severity": self.severity.value if isinstance(self.severity, Severity) else str(self.severity),
            "title": self.title,
            "message": self.message,
            "recommendation": self.recommendation,
            "impact_score": self.impact_score,
        }


@dataclass
class CategoryScore:
    name: str
    score: int  # 0 to 100
    passed_count: int = 0
    warning_count: int = 0
    error_count: int = 0

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class SeoScore:
    overall: int  # 0 to 100
    grade: str   # A+, A, B, C, D, F
    categories: Dict[str, CategoryScore] = field(default_factory=dict)

    @classmethod
    def calculate_grade(cls, score: int) -> str:
        if score >= 95:
            return "A+"
        elif score >= 90:
            return "A"
        elif score >= 80:
            return "B"
        elif score >= 70:
            return "C"
        elif score >= 60:
            return "D"
        else:
            return "F"

    def to_dict(self) -> Dict[str, Any]:
        return {
            "overall": self.overall,
            "grade": self.grade,
            "categories": {k: v.to_dict() for k, v in self.categories.items()},
        }


@dataclass
class MetaInfo:
    title: Optional[str] = None
    title_length: int = 0
    description: Optional[str] = None
    description_length: int = 0
    canonical: Optional[str] = None
    robots: Optional[str] = None
    viewport: Optional[str] = None
    charset: Optional[str] = None
    favicon: Optional[str] = None
    language: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class HeadingItem:
    tag: str
    text: str

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class ContentInfo:
    word_count: int = 0
    reading_time_minutes: float = 0.0
    h1_tags: List[str] = field(default_factory=list)
    h2_tags: List[str] = field(default_factory=list)
    h3_tags: List[str] = field(default_factory=list)
    total_headings: int = 0
    top_keywords: List[Dict[str, Any]] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class LinkItem:
    href: str
    text: str
    is_external: bool
    is_nofollow: bool
    has_rel_noopener: bool

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class LinksInfo:
    total_links: int = 0
    internal_links: int = 0
    external_links: int = 0
    nofollow_links: int = 0
    empty_anchors: int = 0
    generic_anchors: int = 0
    sample_links: List[Dict[str, Any]] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class ImageItem:
    src: str
    alt: Optional[str] = None
    has_alt: bool = False
    is_modern_format: bool = False

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class ImagesInfo:
    total_images: int = 0
    missing_alt: int = 0
    empty_alt: int = 0
    modern_formats_count: int = 0  # WebP, AVIF, SVG
    formats_breakdown: Dict[str, int] = field(default_factory=dict)
    sample_images: List[Dict[str, Any]] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class SocialInfo:
    og_title: Optional[str] = None
    og_description: Optional[str] = None
    og_image: Optional[str] = None
    og_url: Optional[str] = None
    og_type: Optional[str] = None
    twitter_card: Optional[str] = None
    twitter_title: Optional[str] = None
    twitter_description: Optional[str] = None
    twitter_image: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class TechnicalInfo:
    is_https: bool = False
    hsts_enabled: bool = False
    x_content_type_options: Optional[str] = None
    x_frame_options: Optional[str] = None
    content_security_policy: bool = False
    robots_txt_found: Optional[bool] = None
    sitemap_found: Optional[bool] = None
    headers: Dict[str, str] = field(default_factory=dict)

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class PerformanceInfo:
    status_code: int = 0
    response_time_ms: float = 0.0
    page_size_bytes: int = 0
    page_size_kb: float = 0.0
    is_compressed: bool = False
    content_encoding: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class SchemaInfo:
    json_ld_count: int = 0
    microdata_count: int = 0
    detected_types: List[str] = field(default_factory=list)
    has_schema: bool = False

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class AuditResult:
    url: str
    timestamp: str
    score: SeoScore
    meta: MetaInfo
    content: ContentInfo
    links: LinksInfo
    images: ImagesInfo
    social: SocialInfo
    technical: TechnicalInfo
    performance: PerformanceInfo
    schema: SchemaInfo
    issues: List[Issue] = field(default_factory=list)

    @property
    def passed_issues(self) -> List[Issue]:
        return [i for i in self.issues if i.severity == Severity.PASS]

    @property
    def warnings(self) -> List[Issue]:
        return [i for i in self.issues if i.severity == Severity.WARNING]

    @property
    def errors(self) -> List[Issue]:
        return [i for i in self.issues if i.severity == Severity.ERROR]

    @property
    def notices(self) -> List[Issue]:
        return [i for i in self.issues if i.severity == Severity.NOTICE]

    def to_dict(self) -> Dict[str, Any]:
        return {
            "url": self.url,
            "timestamp": self.timestamp,
            "score": self.score.to_dict(),
            "meta": self.meta.to_dict(),
            "content": self.content.to_dict(),
            "links": self.links.to_dict(),
            "images": self.images.to_dict(),
            "social": self.social.to_dict(),
            "technical": self.technical.to_dict(),
            "performance": self.performance.to_dict(),
            "schema": self.schema.to_dict(),
            "issues": [issue.to_dict() for issue in self.issues],
            "stats": {
                "total_checks": len(self.issues),
                "passed": len(self.passed_issues),
                "warnings": len(self.warnings),
                "errors": len(self.errors),
                "notices": len(self.notices),
            },
        }

    def to_json(self, indent: int = 2) -> str:
        return json.dumps(self.to_dict(), indent=indent)
