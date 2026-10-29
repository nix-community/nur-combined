import { Plugin, MarkdownView, WorkspaceLeaf, Notice, debounce } from "obsidian";
import { DEFAULT_SETTINGS, SEOWebCheckerSettings } from "./types";
import { MarkdownSEOAnalyzer } from "./analyzer";
import { SEOWebCheckerView, VIEW_TYPE_SEO_AUDIT } from "./view";
import { SEOWebCheckerSettingTab } from "./settings";

export default class SEOWebCheckerPlugin extends Plugin {
  settings: SEOWebCheckerSettings;
  analyzer: MarkdownSEOAnalyzer;

  async onload() {
    await this.loadSettings();
    this.analyzer = new MarkdownSEOAnalyzer(this.settings);

    // Register Sidebar View
    this.registerView(
      VIEW_TYPE_SEO_AUDIT,
      (leaf) => new SEOWebCheckerView(leaf, this)
    );

    // Ribbon Icon (Gauge / Search)
    this.addRibbonIcon("gauge", "SEOWebChecker SEO Audit", () => {
      void this.activateView();
    });

    // Commands
    this.addCommand({
      id: "open-seo-audit-view",
      name: "Open SEO Audit Sidebar",
      callback: () => {
        void this.activateView();
      },
    });

    this.addCommand({
      id: "audit-current-note",
      name: "Audit Current Note",
      checkCallback: (checking: boolean) => {
        const view = this.app.workspace.getActiveViewOfType(MarkdownView);
        if (view) {
          if (!checking) {
            this.triggerAudit();
            new Notice("SEOWebChecker: Audit updated for active note.");
          }
          return true;
        }
        return false;
      },
    });

    this.addCommand({
      id: "insert-seo-frontmatter-template",
      name: "Insert SEO Frontmatter Template",
      editorCallback: (editor, view) => {
        const title = view.file ? view.file.basename : "Article Title";
        const template = `---\ntitle: "${title}"\ndescription: "Write a compelling 120-165 character summary describing the core value of this article."\ncanonical: "https://example.com/blog/article-slug"\nfocus_keyword: "primary target term"\nslug: "${title.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "")}"\n---\n\n`;

        const curDoc = editor.getValue();
        if (curDoc.startsWith("---")) {
          new Notice("Note already contains YAML frontmatter.");
        } else {
          editor.replaceRange(template, { line: 0, ch: 0 });
          new Notice("Inserted SEO frontmatter template.");
          this.triggerAudit();
        }
      },
    });

    // Settings Tab
    this.addSettingTab(new SEOWebCheckerSettingTab(this.app, this));

    // Realtime editor change debouncer
    const debouncedAudit = debounce(
      () => {
        if (this.settings.enableRealtimeAudit) {
          this.triggerAudit();
        }
      },
      600,
      true
    );

    this.registerEvent(
      this.app.workspace.on("editor-change", () => {
        debouncedAudit();
      })
    );

    this.registerEvent(
      this.app.workspace.on("active-leaf-change", () => {
        this.triggerAudit();
      })
    );
  }

  onunload() {
    // Obsidian automatically cleans up registered views and events
  }

  async loadSettings() {
    const loaded = (await this.loadData()) as Partial<SEOWebCheckerSettings> | null;
    this.settings = Object.assign({}, DEFAULT_SETTINGS, loaded ?? {});
  }

  async saveSettings() {
    await this.saveData(this.settings);
    this.analyzer = new MarkdownSEOAnalyzer(this.settings);
    this.triggerAudit();
  }

  async activateView() {
    const { workspace } = this.app;
    let leaf: WorkspaceLeaf | null = null;
    const leaves = workspace.getLeavesOfType(VIEW_TYPE_SEO_AUDIT);

    if (leaves.length > 0) {
      leaf = leaves[0];
    } else {
      leaf = workspace.getRightLeaf(false);
      if (leaf) {
        await leaf.setViewState({
          type: VIEW_TYPE_SEO_AUDIT,
          active: true,
        });
      }
    }

    if (leaf) {
      await workspace.revealLeaf(leaf);
      this.triggerAudit();
    }
  }

  public triggerAudit() {
    const activeView = this.app.workspace.getActiveViewOfType(MarkdownView);
    if (!activeView || !activeView.file) {
      return;
    }

    const content = activeView.editor.getValue();
    const noteTitle = activeView.file.basename;
    const result = this.analyzer.analyze(content, noteTitle);

    const leaves = this.app.workspace.getLeavesOfType(VIEW_TYPE_SEO_AUDIT);
    leaves.forEach((leaf) => {
      if (leaf.view instanceof SEOWebCheckerView) {
        leaf.view.updateAudit(result);
      }
    });
  }
}
