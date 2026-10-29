"""SEOWebChecker SEO Audit SDK
Lightweight open-source client SDK for SEO auditing and website analysis.
Official website: https://seowebchecker.com/
"""

from seowebchecker_seoaudit.models import (
    AuditResult,
    SeoScore,
    CategoryScore,
    Issue,
    Severity,
    Category,
    MetaInfo,
    ContentInfo,
    LinksInfo,
    ImagesInfo,
    SocialInfo,
    TechnicalInfo,
    PerformanceInfo,
    SchemaInfo,
)
from seowebchecker_seoaudit.auditor import SEOAuditor
from seowebchecker_seoaudit.client import SeoWebCheckerClient

__version__ = "1.0.0"
__author__ = "SEOWebChecker"
__email__ = "support@seowebchecker.com"
__url__ = "https://seowebchecker.com/"

__all__ = [
    "SEOAuditor",
    "SeoWebCheckerClient",
    "AuditResult",
    "SeoScore",
    "CategoryScore",
    "Issue",
    "Severity",
    "Category",
    "MetaInfo",
    "ContentInfo",
    "LinksInfo",
    "ImagesInfo",
    "SocialInfo",
    "TechnicalInfo",
    "PerformanceInfo",
    "SchemaInfo",
    "__version__",
]
