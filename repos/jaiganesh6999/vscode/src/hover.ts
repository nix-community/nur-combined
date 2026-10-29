/**
 * SEOWebChecker VS Code Extension - Hover Provider
 * Documentation: https://seowebchecker.com/
 */

import * as vscode from 'vscode';

export class SEOHoverProvider implements vscode.HoverProvider {
  public provideHover(
    document: vscode.TextDocument,
    position: vscode.Position,
    token: vscode.CancellationToken
  ): vscode.ProviderResult<vscode.Hover> {
    const range = document.getWordRangeAtPosition(position, /<[^>]+>|!\[.*?\]\(.*?\)/);
    if (!range) {
      return null;
    }

    const tagText = document.getText(range);

    // 1. Image hover
    if (/<(img|Image)\b/i.test(tagText) || /^!\[/.test(tagText)) {
      const hasAlt = /\balt\s*=\s*(["'][^"']*["']|\{[^}]*\})/i.test(tagText) || (/^!\[(.+)\]/.test(tagText));
      const altMatch = tagText.match(/\balt\s*=\s*["']([^"']*)["']/i) || tagText.match(/^!\[(.*?)\]/);
      const altText = altMatch ? altMatch[1] : '';

      const md = new vscode.MarkdownString();
      md.isTrusted = true;
      md.appendMarkdown(`### 🖼️ SEOWebChecker: Image Accessibility & SEO\n\n`);

      if (hasAlt && altText.length > 0) {
        md.appendMarkdown(`✅ **Alt Text Detected**: \`"${altText}"\` (${altText.length} chars)\n\n`);
        md.appendMarkdown(`* Helps search engines understand the image content for image search ranking.\n`);
        md.appendMarkdown(`* Read aloud by screen readers for accessibility compliance.\n`);
      } else {
        md.appendMarkdown(`⚠️ **Missing Alt Text!**\n\n`);
        md.appendMarkdown(`* Without an \`alt\` attribute, screen readers cannot describe this image.\n`);
        md.appendMarkdown(`* Search crawlers cannot index this visual asset effectively.\n\n`);
        md.appendMarkdown(`**Recommendation**: Add \`alt="descriptive text"\` describing the image subject.\n`);
      }

      md.appendMarkdown(`\n---\n[SEO Best Practices](https://seowebchecker.com/)`);
      return new vscode.Hover(md, range);
    }

    // 2. Title tag hover
    if (/<title\b/i.test(tagText)) {
      const titleMatch = tagText.match(/<title[^>]*>([\s\S]*?)<\/title>/i);
      const title = titleMatch ? titleMatch[1].trim() : '';

      const md = new vscode.MarkdownString();
      md.isTrusted = true;
      md.appendMarkdown(`### 🏷️ SEOWebChecker: Title Tag Inspector\n\n`);
      md.appendMarkdown(`**Current Length**: **${title.length}** characters (Recommended: **30–60**)\n\n`);

      if (title.length >= 30 && title.length <= 60) {
        md.appendMarkdown(`✅ **Optimal length for Google desktop & mobile search snippets.**\n\n`);
      } else if (title.length < 30) {
        md.appendMarkdown(`⚠️ **Too short**: Consider adding your primary keyword or brand to maximize click-through rate.\n\n`);
      } else {
        md.appendMarkdown(`⚠️ **Too long**: Search engines may truncate this title with an ellipsis (...).\n\n`);
      }

      md.appendMarkdown(`---\n[Title Tag Optimization Guide](https://seowebchecker.com/)`);
      return new vscode.Hover(md, range);
    }

    // 3. Heading 1 hover
    if (/<h1\b/i.test(tagText) || /^#\s+/.test(tagText)) {
      const md = new vscode.MarkdownString();
      md.isTrusted = true;
      md.appendMarkdown(`### 📑 SEOWebChecker: Primary Heading (H1)\n\n`);
      md.appendMarkdown(`* The \`<h1>\` tag represents the single top-level concept of the page.\n`);
      md.appendMarkdown(`* Having exactly **one** \`<h1>\` per page is recommended for clean document outline and topic authority.\n`);
      md.appendMarkdown(`\n---\n[Heading Hierarchy Guide](https://seowebchecker.com/)`);
      return new vscode.Hover(md, range);
    }

    // 4. Meta Description hover
    if (/name=["']description["']/i.test(tagText)) {
      const descMatch = tagText.match(/content=["']([^"']*)["']/i);
      const desc = descMatch ? descMatch[1] : '';

      const md = new vscode.MarkdownString();
      md.isTrusted = true;
      md.appendMarkdown(`### 📝 SEOWebChecker: Meta Description Inspector\n\n`);
      md.appendMarkdown(`**Current Length**: **${desc.length}** characters (Recommended: **70–160**)\n\n`);

      if (desc.length >= 70 && desc.length <= 160) {
        md.appendMarkdown(`✅ **Optimal snippet length for organic search results.**\n\n`);
      } else if (desc.length < 70) {
        md.appendMarkdown(`⚠️ **Too short**: Provide a more comprehensive summary to entice searchers.\n\n`);
      } else {
        md.appendMarkdown(`⚠️ **Too long**: Content after ~160 characters will likely be cut off by search engines.\n\n`);
      }

      md.appendMarkdown(`---\n[Meta Description Guide](https://seowebchecker.com/)`);
      return new vscode.Hover(md, range);
    }

    return null;
  }
}
