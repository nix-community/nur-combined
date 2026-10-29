"""Content and headings check engine for SEO audit."""

import re
from collections import Counter
from typing import Tuple, List, Dict, Any
from seowebchecker_seoaudit.models import ContentInfo, Issue, Severity, Category

try:
    from bs4 import BeautifulSoup
except ImportError:
    BeautifulSoup = None

STOP_WORDS = {
    "a", "about", "above", "after", "again", "against", "all", "am", "an", "and", "any", "are",
    "as", "at", "be", "because", "been", "before", "being", "below", "between", "both", "but",
    "by", "can", "did", "do", "does", "doing", "don", "down", "during", "each", "few", "for",
    "from", "further", "had", "has", "have", "having", "he", "her", "here", "hers", "herself",
    "him", "himself", "his", "how", "i", "if", "in", "into", "is", "it", "its", "itself", "just",
    "me", "more", "most", "my", "myself", "no", "nor", "not", "now", "of", "off", "on", "once",
    "only", "or", "other", "our", "ours", "ourselves", "out", "over", "own", "s", "same", "she",
    "should", "so", "some", "such", "than", "that", "the", "their", "theirs", "them", "themselves",
    "then", "there", "these", "they", "this", "those", "through", "to", "too", "under", "until",
    "up", "very", "was", "we", "were", "what", "when", "where", "which", "while", "who", "whom",
    "why", "will", "with", "you", "your", "yours", "yourself", "yourselves"
}


def extract_content(html: str) -> Tuple[ContentInfo, List[Issue]]:
    issues: List[Issue] = []
    content = ContentInfo()

    clean_text = ""
    h1s: List[str] = []
    h2s: List[str] = []
    h3s: List[str] = []

    if BeautifulSoup:
        soup = BeautifulSoup(html, "html.parser")

        # Strip scripts, styles, noscript
        for elem in soup(["script", "style", "noscript", "svg", "header", "footer", "nav"]):
            elem.extract()

        # Headings
        for tag in soup.find_all(["h1", "h2", "h3"]):
            text = tag.get_text().strip()
            if tag.name == "h1":
                h1s.append(text)
            elif tag.name == "h2":
                h2s.append(text)
            elif tag.name == "h3":
                h3s.append(text)

        clean_text = soup.get_text()
    else:
        # Regex fallback
        h1_matches = re.findall(r'<h1[^>]*>(.*?)</h1>', html, re.IGNORECASE | re.DOTALL)
        h1s = [re.sub(r'<[^>]+>', '', m).strip() for m in h1_matches]

        h2_matches = re.findall(r'<h2[^>]*>(.*?)</h2>', html, re.IGNORECASE | re.DOTALL)
        h2s = [re.sub(r'<[^>]+>', '', m).strip() for m in h2_matches]

        h3_matches = re.findall(r'<h3[^>]*>(.*?)</h3>', html, re.IGNORECASE | re.DOTALL)
        h3s = [re.sub(r'<[^>]+>', '', m).strip() for m in h3_matches]

        # Strip html tags
        clean_text = re.sub(r'<script.*?</script>', ' ', html, flags=re.IGNORECASE | re.DOTALL)
        clean_text = re.sub(r'<style.*?</style>', ' ', clean_text, flags=re.IGNORECASE | re.DOTALL)
        clean_text = re.sub(r'<[^>]+>', ' ', clean_text)

    # Word count & reading time
    words = re.findall(r'\b[a-zA-Z0-9_\'-]{2,}\b', clean_text.lower())
    content.word_count = len(words)
    content.reading_time_minutes = round(content.word_count / 200, 1) if content.word_count > 0 else 0.0

    content.h1_tags = h1s
    content.h2_tags = h2s
    content.h3_tags = h3s
    content.total_headings = len(h1s) + len(h2s) + len(h3s)

    # Top keywords (non stop words)
    filtered_words = [w for w in words if w not in STOP_WORDS and len(w) > 2]
    counter = Counter(filtered_words)
    top_kw = []
    for word, count in counter.most_common(10):
        density = round((count / len(words)) * 100, 2) if len(words) > 0 else 0.0
        top_kw.append({
            "keyword": word,
            "count": count,
            "density_percent": density,
        })
    content.top_keywords = top_kw

    # Rule checks
    # H1 check
    if len(h1s) == 0:
        issues.append(Issue(
            id="content-h1-missing",
            category=Category.CONTENT.value,
            severity=Severity.ERROR,
            title="Missing <h1> Tag",
            message="No <h1> heading found on the page.",
            recommendation="Add a single, clear <h1> tag representing the primary topic of the page.",
            impact_score=8,
        ))
    elif len(h1s) == 1:
        if len(h1s[0]) == 0:
            issues.append(Issue(
                id="content-h1-empty",
                category=Category.CONTENT.value,
                severity=Severity.ERROR,
                title="Empty <h1> Tag",
                message="The <h1> tag exists but contains no text.",
                recommendation="Provide meaningful text inside the <h1> tag.",
                impact_score=7,
            ))
        else:
            issues.append(Issue(
                id="content-h1-optimal",
                category=Category.CONTENT.value,
                severity=Severity.PASS,
                title="Single <h1> Heading Configured",
                message=f"Optimal single <h1> detected: '{h1s[0]}'.",
                recommendation="Maintain unique and clear <h1> hierarchy.",
                impact_score=0,
            ))
    else:
        issues.append(Issue(
            id="content-h1-multiple",
            category=Category.CONTENT.value,
            severity=Severity.WARNING,
            title=f"Multiple <h1> Tags Detected ({len(h1s)})",
            message=f"Found {len(h1s)} <h1> headings. Best practice is to have exactly one main <h1> per page.",
            recommendation="Consolidate down to a single <h1> heading and use <h2>/<h3> for sub-sections.",
            impact_score=4,
        ))

    # H2 check
    if len(h2s) == 0:
        issues.append(Issue(
            id="content-h2-missing",
            category=Category.CONTENT.value,
            severity=Severity.WARNING,
            title="No <h2> Subheadings Found",
            message="No <h2> subheadings were found to structure the content.",
            recommendation="Use <h2> subheadings to divide content into logical, scannable sections.",
            impact_score=3,
        ))
    else:
        issues.append(Issue(
            id="content-h2-present",
            category=Category.CONTENT.value,
            severity=Severity.PASS,
            title="Structured Subheadings (<h2>)",
            message=f"Found {len(h2s)} <h2> subheadings structuring the page content.",
            recommendation="Good use of content hierarchy.",
            impact_score=0,
        ))

    # Word Count check
    if content.word_count < 100:
        issues.append(Issue(
            id="content-words-thin",
            category=Category.CONTENT.value,
            severity=Severity.ERROR,
            title="Critically Low Word Count (Thin Content)",
            message=f"Only {content.word_count} words found. Pages with very little text struggle to rank.",
            recommendation="Expand content to at least 300-500 words of informative, original text.",
            impact_score=9,
        ))
    elif content.word_count < 300:
        issues.append(Issue(
            id="content-words-short",
            category=Category.CONTENT.value,
            severity=Severity.WARNING,
            title="Low Word Count",
            message=f"Page has {content.word_count} words (recommended minimum: 300+ words).",
            recommendation="Provide more comprehensive topical coverage to satisfy user search intent.",
            impact_score=4,
        ))
    else:
        issues.append(Issue(
            id="content-words-good",
            category=Category.CONTENT.value,
            severity=Severity.PASS,
            title="Adequate Content Length",
            message=f"Page contains {content.word_count} words (estimated reading time: ~{content.reading_time_minutes} min).",
            recommendation="Good text volume for on-page search indexing.",
            impact_score=0,
        ))

    return content, issues
