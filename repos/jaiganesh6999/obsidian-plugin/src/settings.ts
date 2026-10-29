import { App, PluginSettingTab, Setting } from "obsidian";
import type SEOWebCheckerPlugin from "./main";

export class SEOWebCheckerSettingTab extends PluginSettingTab {
  plugin: SEOWebCheckerPlugin;

  constructor(app: App, plugin: SEOWebCheckerPlugin) {
    super(app, plugin);
    this.plugin = plugin;
  }

  display(): void {
    const { containerEl } = this;
    containerEl.empty();

    new Setting(containerEl).setName("Content targets").setHeading();

    new Setting(containerEl)
      .setName("Target Word Count")
      .setDesc("Ideal comprehensive article word count (default: 1,000 words).")
      .addText((text) =>
        text
          .setPlaceholder("1000")
          .setValue(String(this.plugin.settings.targetWordCount))
          .onChange(async (value) => {
            const num = parseInt(value, 10);
            if (!isNaN(num) && num > 0) {
              this.plugin.settings.targetWordCount = num;
              await this.plugin.saveSettings();
            }
          })
      );

    new Setting(containerEl)
      .setName("Minimum Word Count")
      .setDesc("Threshold below which content is flagged as thin (default: 300 words).")
      .addText((text) =>
        text
          .setPlaceholder("300")
          .setValue(String(this.plugin.settings.minWordCount))
          .onChange(async (value) => {
            const num = parseInt(value, 10);
            if (!isNaN(num) && num > 0) {
              this.plugin.settings.minWordCount = num;
              await this.plugin.saveSettings();
            }
          })
      );

    new Setting(containerEl)
      .setName("Focus Keyword Frontmatter Key")
      .setDesc("YAML frontmatter key to extract focus keywords from (default: focus_keyword).")
      .addText((text) =>
        text
          .setPlaceholder("focus_keyword")
          .setValue(this.plugin.settings.focusKeywordKey)
          .onChange(async (value) => {
            this.plugin.settings.focusKeywordKey = value.trim() || "focus_keyword";
            await this.plugin.saveSettings();
          })
      );

    new Setting(containerEl)
      .setName("Enable Real-Time Audit")
      .setDesc("Automatically update SEO score and diagnostics as you type in Markdown editor.")
      .addToggle((toggle) =>
        toggle
          .setValue(this.plugin.settings.enableRealtimeAudit)
          .onChange(async (value) => {
            this.plugin.settings.enableRealtimeAudit = value;
            await this.plugin.saveSettings();
          })
      );

    const infoBox = containerEl.createDiv({ cls: "seowebchecker-settings-info" });
    infoBox.createEl("p", {
      text: "Powered by SEOWebChecker Enterprise Technical SEO Platform: ",
    });
    const link = infoBox.createEl("a", {
      text: "https://seowebchecker.com/",
      href: "https://seowebchecker.com/",
    });
    link.setAttr("target", "_blank");
  }
}
