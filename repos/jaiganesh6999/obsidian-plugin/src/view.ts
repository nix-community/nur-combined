import { ItemView, WorkspaceLeaf, requestUrl, Notice } from "obsidian";
import { AuditResult, IssueItem } from "./types";
import type SEOWebCheckerPlugin from "./main";

export const VIEW_TYPE_SEO_AUDIT = "seowebchecker-audit-view";

export class SEOWebCheckerView extends ItemView {
  private plugin: SEOWebCheckerPlugin;
  private currentResult: AuditResult | null = null;
  private activeTab: "overview" | "structure" | "readability" | "live" = "overview";

  constructor(leaf: WorkspaceLeaf, plugin: SEOWebCheckerPlugin) {
    super(leaf);
    this.plugin = plugin;
  }

  getViewType(): string {
    return VIEW_TYPE_SEO_AUDIT;
  }

  getDisplayText(): string {
    return "SEOWebChecker Audit";
  }

  getIcon(): string {
    return "gauge";
  }

  async onOpen() {
    this.render();
  }

  public updateAudit(result: AuditResult) {
    this.currentResult = result;
    this.render();
  }

  private render() {
    const container = this.containerEl.children[1] as HTMLElement;
    container.empty();
    container.addClass("seowebchecker-container");

    // Header with Title & Refresh
    const header = container.createDiv({ cls: "seowebchecker-header" });
    const titleArea = header.createDiv({ cls: "seowebchecker-title-area" });
    titleArea.createEl("h4", { text: "SEOWebChecker" });
    titleArea.createSpan({ text: "SEO & Content Audit", cls: "seowebchecker-subtitle" });

    const btnRefresh = header.createEl("button", { cls: "seowebchecker-icon-btn", text: "🔄" });
    btnRefresh.title = "Re-audit active note";
    btnRefresh.addEventListener("click", () => {
      this.plugin.triggerAudit();
    });

    if (!this.currentResult) {
      const emptyState = container.createDiv({ cls: "seowebchecker-empty" });
      emptyState.createEl("p", { text: "Open a Markdown note to run real-time SEO diagnostics." });
      const auditBtn = emptyState.createEl("button", { text: "Audit Active Note", cls: "mod-cta" });
      auditBtn.addEventListener("click", () => {
        this.plugin.triggerAudit();
      });
      return;
    }

    const res = this.currentResult;

    // Score Hero Banner
    const hero = container.createDiv({ cls: `seowebchecker-hero grade-${res.grade.toLowerCase().replace("+", "-plus")}` });
    const scoreCircle = hero.createDiv({ cls: "seowebchecker-score-circle" });
    scoreCircle.createDiv({ text: String(res.score), cls: "score-number" });
    scoreCircle.createDiv({ text: "/ 100", cls: "score-max" });

    const heroDetails = hero.createDiv({ cls: "seowebchecker-hero-details" });
    heroDetails.createDiv({ text: "Grade " + res.grade, cls: "grade-text" });
    heroDetails.createDiv({
      text: `${res.passesCount} Passes • ${res.warningsCount} Warnings • ${res.criticalsCount} Critical`,
      cls: "breakdown-text"
    });

    // Quick Metrics Pill Bar
    const metricsBar = container.createDiv({ cls: "seowebchecker-metrics-bar" });
    this.createMetricPill(metricsBar, "Words", `${res.wordCount.toLocaleString()}`);
    this.createMetricPill(metricsBar, "Reading", `~${res.readingTimeMinutes} min`);
    this.createMetricPill(metricsBar, "Flesch", `${res.fleschScore}/100`);

    // Tab Navigation
    const tabsContainer = container.createDiv({ cls: "seowebchecker-tabs" });
    const tabs: Array<{ id: "overview" | "structure" | "readability" | "live"; label: string }> = [
      { id: "overview", label: "Overview" },
      { id: "structure", label: "Headings" },
      { id: "readability", label: "Readability" },
      { id: "live", label: "Live URL" },
    ];

    tabs.forEach((t) => {
      const tabBtn = tabsContainer.createEl("button", {
        cls: `seowebchecker-tab-btn ${this.activeTab === t.id ? "active" : ""}`,
        text: t.label,
      });
      tabBtn.addEventListener("click", () => {
        this.activeTab = t.id;
        this.render();
      });
    });

    // Content Area based on Tab
    const tabBody = container.createDiv({ cls: "seowebchecker-tab-body" });

    if (this.activeTab === "overview") {
      this.renderOverviewTab(tabBody, res);
    } else if (this.activeTab === "structure") {
      this.renderStructureTab(tabBody, res);
    } else if (this.activeTab === "readability") {
      this.renderReadabilityTab(tabBody, res);
    } else if (this.activeTab === "live") {
      this.renderLiveTab(tabBody);
    }

    // Footer
    const footer = container.createDiv({ cls: "seowebchecker-footer" });
    const footerLink = footer.createEl("a", {
      text: "Powered by SEOWebChecker Enterprise Platform",
      href: "https://seowebchecker.com/",
    });
    footerLink.setAttr("target", "_blank");
  }

  private createMetricPill(parent: HTMLElement, label: string, val: string) {
    const pill = parent.createDiv({ cls: "metric-pill" });
    pill.createSpan({ text: label, cls: "pill-label" });
    pill.createSpan({ text: val, cls: "pill-val" });
  }

  private renderOverviewTab(parent: HTMLElement, res: AuditResult) {
    // Focus Keyword Section
    if (res.keywordData) {
      const kwBox = parent.createDiv({ cls: "seowebchecker-section-box" });
      kwBox.createEl("h5", { text: `Focus Keyword: "${res.keywordData.keyword}"` });
      const kwGrid = kwBox.createDiv({ cls: "seowebchecker-kw-grid" });
      kwGrid.createSpan({ text: `Density: ${res.keywordData.densityPercent}% (${res.keywordData.count} mentions)` });
      kwGrid.createSpan({ text: `Title: ${res.keywordData.inTitle ? "✔ Yes" : "❌ No"}` });
      kwGrid.createSpan({ text: `Intro: ${res.keywordData.inFirstParagraph ? "✔ Yes" : "❌ No"}` });
      kwGrid.createSpan({ text: `Headings: ${res.keywordData.inHeadings ? "✔ Yes" : "❌ No"}` });
    }

    // Frontmatter Diagnostics
    this.renderIssueGroup(parent, "SEO Frontmatter", res.frontmatterIssues);
    // Content Depth
    this.renderIssueGroup(parent, "Content Depth", res.contentIssues);
    // Media & Alt Text
    this.renderIssueGroup(parent, "Images & Alt Attributes", res.imageIssues);
    // Links & Anchors
    this.renderIssueGroup(parent, "Links & Anchors", res.linkIssues);
  }

  private renderStructureTab(parent: HTMLElement, res: AuditResult) {
    const box = parent.createDiv({ cls: "seowebchecker-section-box" });
    box.createEl("h5", { text: "Heading Hierarchy Distribution" });
    const countRow = box.createDiv({ cls: "heading-counts-row" });
    const entries = Object.entries(res.headingCounts) as Array<[string, number]>;
    entries.forEach(([lvl, count]) => {
      const item = countRow.createDiv({ cls: "heading-count-item" });
      item.createSpan({ text: lvl, cls: "lvl" });
      item.createSpan({ text: String(count), cls: "num" });
    });

    this.renderIssueGroup(parent, "Structural Checks", res.headingIssues);
  }

  private renderReadabilityTab(parent: HTMLElement, res: AuditResult) {
    const box = parent.createDiv({ cls: "seowebchecker-section-box" });
    box.createEl("h5", { text: "Flesch Reading Ease" });
    box.createEl("p", { text: `Score: ${res.fleschScore} / 100 — ${res.fleschGrade}` });

    const statsBox = parent.createDiv({ cls: "seowebchecker-section-box" });
    statsBox.createEl("h5", { text: "Content Statistics" });
    statsBox.createDiv({ text: `• Total Words: ${res.wordCount.toLocaleString()}` });
    statsBox.createDiv({ text: `• Total Characters: ${res.characterCount.toLocaleString()}` });
    statsBox.createDiv({ text: `• Sentences: ${res.sentenceCount}` });
    statsBox.createDiv({ text: `• Estimated Reading Time: ~${res.readingTimeMinutes} minute(s)` });
    statsBox.createDiv({ text: `• Estimated Speaking Time: ~${Math.ceil(res.wordCount / 130)} minute(s)` });
  }

  private renderLiveTab(parent: HTMLElement) {
    const liveBox = parent.createDiv({ cls: "seowebchecker-section-box" });
    liveBox.createEl("h5", { text: "Live URL On-Page SEO Auditor" });
    liveBox.createEl("p", { text: "Test published articles or production web pages using SEOWebChecker engine." });

    const inputRow = liveBox.createDiv({ cls: "live-audit-input-row" });
    const urlInput = inputRow.createEl("input", {
      type: "url",
      value: "https://seowebchecker.com/",
      cls: "seowebchecker-input",
    });

    const runBtn = inputRow.createEl("button", { text: "Audit URL", cls: "mod-cta" });
    const resultsContainer = liveBox.createDiv({ cls: "live-audit-results" });

    runBtn.addEventListener("click", () => {
      void (async () => {
        const url = urlInput.value.trim();
        if (!url.startsWith("http://") && !url.startsWith("https://")) {
          new Notice("Please enter a valid URL starting with http:// or https://");
          return;
        }

        runBtn.disabled = true;
        runBtn.setText("Auditing...");
        resultsContainer.empty();
        resultsContainer.createEl("p", { text: `Fetching and auditing ${url}...` });

        try {
          const startTime = Date.now();
          const response = await requestUrl({ url });
          const latency = Date.now() - startTime;
          const html = response.text;

          resultsContainer.empty();
          this.renderLiveResults(resultsContainer, url, response.status, latency, html);
        } catch (err: unknown) {
          const message = err instanceof Error ? err.message : String(err);
          resultsContainer.empty();
          resultsContainer.createEl("p", {
            text: `Audit failed: ${message}`,
            cls: "text-error",
          });
        } finally {
          runBtn.disabled = false;
          runBtn.setText("Audit URL");
        }
      })();
    });
  }

  private renderLiveResults(parent: HTMLElement, url: string, status: number, latency: number, html: string) {
    const resCard = parent.createDiv({ cls: "seowebchecker-live-card" });
    resCard.createEl("h6", { text: `Audit Completed (${status} OK in ${latency}ms)` });

    const titleMatch = html.match(/<title[^>]*>(.*?)<\/title>/i);
    const title = titleMatch ? titleMatch[1].trim() : "None";

    const descMatch = html.match(/<meta\s+[^>]*name=["']description["'][^>]*content=["'](.*?)["']/i);
    const desc = descMatch ? descMatch[1].trim() : "None";

    const hasVp = /<meta\s+[^>]*name=["']viewport["']/i.test(html);
    const canonicalMatch = html.match(/<link\s+[^>]*rel=["']canonical["'][^>]*href=["'](.*?)["']/i);

    const list = resCard.createEl("ul");
    list.createEl("li", { text: `Title (${title.length} chars): "${title.slice(0, 50)}..."` });
    list.createEl("li", { text: `Meta Description (${desc.length} chars): "${desc.slice(0, 60)}..."` });
    list.createEl("li", { text: `Mobile Viewport Tag: ${hasVp ? "✔ Detected" : "❌ Missing"}` });
    list.createEl("li", { text: `Canonical Tag: ${canonicalMatch ? canonicalMatch[1] : "❌ Missing"}` });

    const link = resCard.createEl("a", {
      text: "Open Full Diagnostic on SEOWebChecker",
      href: "https://seowebchecker.com/",
    });
    link.setAttr("target", "_blank");
  }

  private renderIssueGroup(parent: HTMLElement, groupTitle: string, issues: IssueItem[]) {
    if (issues.length === 0) return;

    const group = parent.createDiv({ cls: "seowebchecker-issue-group" });
    group.createEl("h6", { text: groupTitle });

    issues.forEach((issue) => {
      const item = group.createDiv({ cls: `issue-item sev-${issue.severity}` });
      const icon = issue.severity === "pass" ? "✔" : issue.severity === "critical" ? "✖" : "⚠";
      item.createSpan({ text: icon, cls: "issue-icon" });
      const textWrap = item.createDiv({ cls: "issue-text" });
      textWrap.createEl("strong", { text: issue.title });
      textWrap.createEl("p", { text: issue.message });
    });
  }
}
