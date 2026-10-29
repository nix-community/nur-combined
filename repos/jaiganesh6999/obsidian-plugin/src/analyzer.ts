import { AuditResult, IssueItem, KeywordData, SEOWebCheckerSettings } from "./types";

export class MarkdownSEOAnalyzer {
  private settings: SEOWebCheckerSettings;

  constructor(settings: SEOWebCheckerSettings) {
    this.settings = settings;
  }

  public analyze(content: string, noteTitle: string = ""): AuditResult {
    let score = 100;
    const frontmatterIssues: IssueItem[] = [];
    const headingIssues: IssueItem[] = [];
    const contentIssues: IssueItem[] = [];
    const imageIssues: IssueItem[] = [];
    const linkIssues: IssueItem[] = [];

    // 1. Extract Frontmatter
    const fmMatch = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
    const fmString = fmMatch ? fmMatch[1] : "";
    const bodyContent = fmMatch ? content.slice(fmMatch[0].length) : content;

    const fm = this.parseFrontmatter(fmString);

    // Frontmatter Title & Meta Description Checks
    const title = (fm["title"] || fm["seo_title"] || noteTitle || "").trim();
    if (!title) {
      score -= 15;
      frontmatterIssues.push({
        id: "fm-title-missing",
        title: "Missing SEO Title",
        message: "No title defined in YAML frontmatter or note title. Search engines require a descriptive title.",
        severity: "critical",
      });
    } else if (title.length < 30) {
      score -= 5;
      frontmatterIssues.push({
        id: "fm-title-short",
        title: "SEO Title is Too Short",
        message: `Title has only ${title.length} characters (recommended: 30-65 chars).`,
        severity: "warning",
      });
    } else if (title.length > 65) {
      score -= 5;
      frontmatterIssues.push({
        id: "fm-title-long",
        title: "SEO Title Exceeds Snippet Length",
        message: `Title has ${title.length} characters. Google search snippets typically truncate titles over 65 chars.`,
        severity: "warning",
      });
    } else {
      frontmatterIssues.push({
        id: "fm-title-optimal",
        title: "Optimal Title Tag Length",
        message: `Title length (${title.length} chars) is ideal for search snippets.`,
        severity: "pass",
      });
    }

    // Meta Description
    const description = (fm["description"] || fm["meta_description"] || "").trim();
    if (!description) {
      score -= 10;
      frontmatterIssues.push({
        id: "fm-desc-missing",
        title: "Missing Meta Description",
        message: "Add a 'description' key in frontmatter to control your search result snippet.",
        severity: "warning",
      });
    } else if (description.length < 120) {
      score -= 4;
      frontmatterIssues.push({
        id: "fm-desc-short",
        title: "Meta Description is Short",
        message: `Description has ${description.length} characters (recommended: 120-165 chars).`,
        severity: "info",
      });
    } else if (description.length > 165) {
      score -= 4;
      frontmatterIssues.push({
        id: "fm-desc-long",
        title: "Meta Description Too Long",
        message: `Description is ${description.length} characters. Will likely be truncated in search results.`,
        severity: "warning",
      });
    } else {
      frontmatterIssues.push({
        id: "fm-desc-optimal",
        title: "Optimal Meta Description",
        message: `Description length (${description.length} chars) provides a comprehensive snippet summary.`,
        severity: "pass",
      });
    }

    // Canonical & Slug
    if (fm["canonical"]) {
      frontmatterIssues.push({
        id: "fm-canonical-pass",
        title: "Canonical URL Configured",
        message: `Canonical link specified: ${fm["canonical"]}`,
        severity: "pass",
      });
    }

    const slug = (fm["slug"] || "").trim();
    if (slug) {
      if (/^[a-z0-9-]+$/.test(slug)) {
        frontmatterIssues.push({
          id: "fm-slug-valid",
          title: "Clean URL Slug",
          message: `Slug '${slug}' follows SEO-friendly kebab-case standards.`,
          severity: "pass",
        });
      } else {
        score -= 3;
        frontmatterIssues.push({
          id: "fm-slug-invalid",
          title: "Suboptimal URL Slug",
          message: "Slug should only contain lowercase alphanumeric characters and hyphens.",
          severity: "warning",
        });
      }
    }

    // 2. Heading Hierarchy Inspection
    const headingLines = bodyContent.match(/^(#{1,6})\s+(.+)$/gm) || [];
    const headingCounts: { [key: string]: number } = { H1: 0, H2: 0, H3: 0, H4: 0, H5: 0, H6: 0 };
    const headingLevels: number[] = [];
    const headingTexts: string[] = [];

    headingLines.forEach((line) => {
      const match = line.match(/^(#{1,6})\s+(.+)$/);
      if (match) {
        const level = match[1].length;
        const text = match[2].trim();
        headingCounts[`H${level}`] = (headingCounts[`H${level}`] || 0) + 1;
        headingLevels.push(level);
        headingTexts.push(text);
      }
    });

    if (headingCounts["H1"] === 0 && !fm["title"]) {
      score -= 10;
      headingIssues.push({
        id: "heading-no-h1",
        title: "No H1 Heading Found",
        message: "Every web page should have a primary H1 heading (# Main Title).",
        severity: "critical",
      });
    } else if (headingCounts["H1"] > 1) {
      score -= 5;
      headingIssues.push({
        id: "heading-multiple-h1",
        title: "Multiple H1 Headings Detected",
        message: `Found ${headingCounts["H1"]} H1 headings. Best practice is a single H1 per document.`,
        severity: "warning",
      });
    } else if (headingCounts["H1"] === 1) {
      headingIssues.push({
        id: "heading-single-h1",
        title: "Single Primary H1 Heading",
        message: "Document correctly maintains a single primary H1 heading.",
        severity: "pass",
      });
    }

    // Skipped heading levels (e.g. H1 to H3 without H2)
    let skippedLevel = false;
    for (let i = 0; i < headingLevels.length - 1; i++) {
      if (headingLevels[i + 1] > headingLevels[i] + 1) {
        skippedLevel = true;
        break;
      }
    }
    if (skippedLevel) {
      score -= 5;
      headingIssues.push({
        id: "heading-skipped-level",
        title: "Skipped Heading Levels",
        message: "Headings jump down more than one level (e.g., H1 directly to H3). Maintain sequential hierarchy.",
        severity: "warning",
      });
    } else if (headingLevels.length > 0) {
      headingIssues.push({
        id: "heading-hierarchy-valid",
        title: "Logical Heading Structure",
        message: "Heading levels progress sequentially without skipping tiers.",
        severity: "pass",
      });
    }

    // 3. Word Count & Readability Metrics
    const cleanText = this.cleanMarkdownText(bodyContent);
    const words = cleanText.trim().split(/\s+/).filter((w) => w.length > 0);
    const wordCount = words.length;
    const charCount = cleanText.length;
    const sentences = cleanText.split(/[.!?]+/).filter((s) => s.trim().length > 0);
    const sentenceCount = Math.max(1, sentences.length);

    if (wordCount < this.settings.minWordCount) {
      score -= 15;
      contentIssues.push({
        id: "content-thin",
        title: "Thin Content Warning",
        message: `Note contains ${wordCount} words (minimum recommended: ${this.settings.minWordCount} words for organic search indexing).`,
        severity: "critical",
      });
    } else if (wordCount < this.settings.targetWordCount) {
      score -= 5;
      contentIssues.push({
        id: "content-moderate",
        title: "Acceptable Word Volume",
        message: `Document has ${wordCount} words. Expanding toward ${this.settings.targetWordCount} words can improve comprehensive coverage.`,
        severity: "info",
      });
    } else {
      contentIssues.push({
        id: "content-comprehensive",
        title: "Comprehensive Content Depth",
        message: `Document has ${wordCount} words, reaching in-depth topic authority target.`,
        severity: "pass",
      });
    }

    // Flesch Reading Ease
    const syllables = words.reduce((acc, word) => acc + this.countSyllables(word), 0);
    const wordsPerSentence = wordCount / sentenceCount;
    const syllablesPerWord = wordCount > 0 ? syllables / wordCount : 1;
    const fleschRaw = 206.835 - 1.015 * wordsPerSentence - 84.6 * syllablesPerWord;
    const fleschScore = Math.round(Math.max(0, Math.min(100, fleschRaw)));

    let fleschGrade = "Standard";
    if (fleschScore >= 90) fleschGrade = "Very Easy (5th Grade)";
    else if (fleschScore >= 80) fleschGrade = "Easy (6th Grade)";
    else if (fleschScore >= 70) fleschGrade = "Fairly Easy (7th Grade)";
    else if (fleschScore >= 60) fleschGrade = "Standard (8th-9th Grade)";
    else if (fleschScore >= 50) fleschGrade = "Fairly Difficult (High School)";
    else if (fleschScore >= 30) fleschGrade = "Difficult (College)";
    else fleschGrade = "Very Difficult (Graduate)";

    if (fleschScore < 50) {
      score -= 5;
      contentIssues.push({
        id: "readability-complex",
        title: "High Reading Difficulty",
        message: `Flesch Reading Ease is ${fleschScore}/100 (${fleschGrade}). Consider shorter sentences and simpler vocabulary.`,
        severity: "warning",
      });
    } else {
      contentIssues.push({
        id: "readability-accessible",
        title: "Accessible Readability",
        message: `Flesch Reading Ease is ${fleschScore}/100 (${fleschGrade}), accessible to general audiences.`,
        severity: "pass",
      });
    }

    // 4. Images & Alt Text
    const imageRegex = /!\[(.*?)\]\((.*?)\)/g;
    let imgMatch: RegExpExecArray | null;
    let totalImages = 0;
    let missingAltCount = 0;
    while ((imgMatch = imageRegex.exec(bodyContent)) !== null) {
      totalImages++;
      const alt = (imgMatch[1] || "").trim();
      if (!alt) {
        missingAltCount++;
      }
    }

    if (totalImages === 0) {
      contentIssues.push({
        id: "images-none",
        title: "No Visual Media Detected",
        message: "Articles with images, diagrams, or charts tend to have higher user engagement and dwell time.",
        severity: "info",
      });
    } else if (missingAltCount > 0) {
      score -= Math.min(10, missingAltCount * 4);
      imageIssues.push({
        id: "images-missing-alt",
        title: "Images Missing Alt Text",
        message: `${missingAltCount} of ${totalImages} images lack descriptive alt attributes for accessibility and image search.`,
        severity: "critical",
      });
    } else {
      imageIssues.push({
        id: "images-alt-valid",
        title: "All Images Have Alt Text",
        message: `All ${totalImages} images have descriptive alt text tags.`,
        severity: "pass",
      });
    }

    // 5. Links & Anchor Text
    const internalLinkRegex = /\[\[(.*?)\]\]/g;
    let intMatch: RegExpExecArray | null;
    let internalLinksCount = 0;
    while ((intMatch = internalLinkRegex.exec(bodyContent)) !== null) {
      internalLinksCount++;
    }

    const mdLinkRegex = /\[(.*?)\]\((https?:\/\/.*?)\)/g;
    let mdMatch: RegExpExecArray | null;
    let markdownLinksCount = 0;
    let weakAnchorCount = 0;
    const weakAnchors = ["here", "click here", "read more", "link", "more", "this", "learn more"];

    while ((mdMatch = mdLinkRegex.exec(bodyContent)) !== null) {
      markdownLinksCount++;
      const anchor = (mdMatch[1] || "").trim().toLowerCase();
      if (weakAnchors.includes(anchor)) {
        weakAnchorCount++;
      }
    }

    if (internalLinksCount === 0 && markdownLinksCount === 0) {
      linkIssues.push({
        id: "links-none",
        title: "No Hyperlinks Found",
        message: "Consider adding internal reference links and helpful citations to related resources.",
        severity: "info",
      });
    } else {
      linkIssues.push({
        id: "links-present",
        title: "Hyperlinks Detected",
        message: `Found ${internalLinksCount} internal note links and ${markdownLinksCount} external web references.`,
        severity: "pass",
      });
    }

    if (weakAnchorCount > 0) {
      score -= 4;
      linkIssues.push({
        id: "links-weak-anchor",
        title: "Generic Anchor Text Detected",
        message: `${weakAnchorCount} links use generic anchors (e.g. 'click here'). Use descriptive keywords indicating the target topic.`,
        severity: "warning",
      });
    }

    // 6. Focus Keyword Analysis
    let keywordData: KeywordData | null = null;
    const focusKeyword = (fm[this.settings.focusKeywordKey] || fm["focus_keyword"] || fm["keyword"] || "").trim().toLowerCase();

    if (focusKeyword) {
      const escaped = focusKeyword.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
      const kwRegex = new RegExp(`\\b${escaped}\\b`, "gi");
      const kwMatches = cleanText.match(kwRegex) || [];
      const kwCount = kwMatches.length;

      const kwWordCount = focusKeyword.split(/\s+/).length;
      const density = wordCount > 0 ? (kwCount * kwWordCount / wordCount) * 100 : 0;
      const densityRounded = Math.round(density * 10) / 10;

      const inTitle = title.toLowerCase().includes(focusKeyword);
      const inDescription = description.toLowerCase().includes(focusKeyword);

      const firstParagraph = cleanText.split(/\n\s*\n/)[0] || "";
      const inFirstParagraph = firstParagraph.toLowerCase().includes(focusKeyword);

      const inHeadings = headingTexts.some((h) => h.toLowerCase().includes(focusKeyword));

      keywordData = {
        keyword: focusKeyword,
        count: kwCount,
        densityPercent: densityRounded,
        inTitle,
        inFirstParagraph,
        inHeadings,
        inDescription,
      };

      if (!inTitle) {
        score -= 5;
        contentIssues.push({
          id: "kw-title-missing",
          title: "Focus Keyword Missing in Title",
          message: `Focus keyword '${focusKeyword}' was not found in the title tag.`,
          severity: "warning",
        });
      }

      if (!inFirstParagraph && wordCount > 100) {
        score -= 4;
        contentIssues.push({
          id: "kw-intro-missing",
          title: "Focus Keyword Missing in Introduction",
          message: `Introduce '${focusKeyword}' within the first 100 words of the article.`,
          severity: "warning",
        });
      }

      if (densityRounded > 3.0) {
        score -= 8;
        contentIssues.push({
          id: "kw-density-high",
          title: "Potential Keyword Stuffing",
          message: `Keyword density is ${densityRounded}%. Recommended threshold is 1.0% to 2.5% for organic reading flow.`,
          severity: "critical",
        });
      } else if (densityRounded < 0.5 && wordCount > 300) {
        contentIssues.push({
          id: "kw-density-low",
          title: "Low Keyword Frequency",
          message: `Keyword density is only ${densityRounded}%. Naturally mention the focus term more across key sections.`,
          severity: "info",
        });
      } else {
        contentIssues.push({
          id: "kw-density-optimal",
          title: "Optimal Keyword Density",
          message: `Keyword density is ${densityRounded}% (count: ${kwCount}), aligning with organic search standards.`,
          severity: "pass",
        });
      }
    }

    score = Math.max(0, Math.min(100, Math.round(score)));
    let grade: "A+" | "A" | "B" | "C" | "F" = "F";
    if (score >= 95) grade = "A+";
    else if (score >= 90) grade = "A";
    else if (score >= 80) grade = "B";
    else if (score >= 70) grade = "C";
    else grade = "F";

    const allIssues = [
      ...frontmatterIssues,
      ...headingIssues,
      ...contentIssues,
      ...imageIssues,
      ...linkIssues,
    ];

    const passesCount = allIssues.filter((i) => i.severity === "pass").length;
    const warningsCount = allIssues.filter((i) => i.severity === "warning").length;
    const criticalsCount = allIssues.filter((i) => i.severity === "critical").length;

    return {
      score,
      grade,
      wordCount,
      characterCount: charCount,
      sentenceCount,
      readingTimeMinutes: Math.max(1, Math.ceil(wordCount / 200)),
      fleschScore,
      fleschGrade,
      headingCounts,
      headingIssues,
      frontmatterIssues,
      contentIssues,
      imageIssues,
      linkIssues,
      keywordData,
      passesCount,
      warningsCount,
      criticalsCount,
      timestamp: new Date().toISOString(),
      platformUrl: "https://seowebchecker.com/",
    };
  }

  private parseFrontmatter(yamlStr: string): { [key: string]: string } {
    const result: { [key: string]: string } = {};
    if (!yamlStr) return result;

    const lines = yamlStr.split("\n");
    for (const line of lines) {
      const idx = line.indexOf(":");
      if (idx > 0) {
        const key = line.slice(0, idx).trim().toLowerCase();
        let val = line.slice(idx + 1).trim();
        if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
          val = val.slice(1, -1);
        }
        result[key] = val;
      }
    }
    return result;
  }

  private cleanMarkdownText(md: string): string {
    return md
      .replace(/```[\s\S]*?```/g, " ") // code blocks
      .replace(/`.*?`/g, " ") // inline code
      .replace(/<[^>]+>/g, " ") // html tags
      .replace(/!\[.*?\]\(.*?\)/g, " ") // images
      .replace(/\[(.*?)\]\(.*?\)/g, "$1") // link labels
      .replace(/\[\[(?:[^|\]]*\|)?([^\]]+)\]\]/g, "$1") // wiki links
      .replace(/^[#\s*>-]+/gm, " ") // headings, quotes, bullets
      .replace(/\*\*|__|\*|_|~~/g, " "); // emphasis
  }

  private countSyllables(word: string): number {
    word = word.toLowerCase().replace(/[^a-z]/g, "");
    if (word.length <= 3) return 1;
    word = word.replace(/(?:[^laeiouy]es|ed|[^laeiouy]e)$/, "");
    word = word.replace(/^y/, "");
    const matches = word.match(/[aeiouy]{1,2}/g);
    return matches ? Math.max(1, matches.length) : 1;
  }
}
