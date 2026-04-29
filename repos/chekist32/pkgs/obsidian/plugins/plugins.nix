{ mkObsidianPlugin }:
{
  dataview = mkObsidianPlugin {
    name = "dataview";
    version = "0.5.68";
    repo = "https://github.com/blacksmithgu/obsidian-dataview";
    mainJsSha256 = "sha256-eU6ert5zkgu41UsO2k9d4hgtaYzGOHdFAPJPFLzU2gs=";
    manifestSha256 = "sha256-kjXbRxEtqBuFWRx57LmuJXTl5yIHBW6XZHL5BhYoYYU=";
    stylesCssSha256 = "sha256-MwbdkDLgD5ibpyM6N/0lW8TT9DQM7mYXYulS8/aqHek=";
    description = "Complex data views for the data-obsessed.";
  };
  templater-obsidian = mkObsidianPlugin {
    name = "templater-obsidian";
    version = "2.20.0";
    repo = "https://github.com/SilentVoid13/Templater";
    mainJsSha256 = "sha256-gezP+Bli2vjsci7S3v95V7P6vuJEr8n7FcOee40pQ+M=";
    manifestSha256 = "sha256-R/WfFoPsqYvpqftY684883VXry9ZR7R7y6no9UxWfq4=";
    stylesCssSha256 = "sha256-99TuW9TsHQMu2h9OHaSB5xPFevlk7B5V0xSU8IYGjR4=";
    description = "Create and use templates";
  };
  obsidian-tasks-plugin = mkObsidianPlugin {
    name = "obsidian-tasks-plugin";
    version = "7.23.1";
    repo = "https://github.com/obsidian-tasks-group/obsidian-tasks";
    mainJsSha256 = "sha256-fI3xbq/iMX+mHW3aJHtOi8RQ8F3pp88hXpVaAxiPiE8=";
    manifestSha256 = "sha256-fLzETXzW22Wkmw2UIw+JvDhC/PioOFqO5ia5jY/UzYQ=";
    stylesCssSha256 = "sha256-tKlV/OX3z5UzSOVqlOmuyu43FxvZgzeaq79AyPWLLq4=";
    description = "Track tasks across your vault. Supports due dates, recurring tasks, done dates, sub-set of checklist items, and filtering.";
  };
  calendar = mkObsidianPlugin {
    name = "calendar";
    version = "1.5.13";
    repo = "https://github.com/FBarrca/obsidian-calendar-plugin";
    mainJsSha256 = "sha256-bjwygwcMn3QYHZTOsyFboNUy12vMGAK18nvvDBwvtNA=";
    manifestSha256 = "sha256-Za/JV/4w2QRAQtldmZoE62t/5/ZjIQzbk4dUXHUxASE=";
    stylesCssSha256 = "sha256-gl/sngbhdUWBZ2M+S52MTuINiRXTyeO98oC3PdRu22o=";
    description = "Calendar view of your daily notes";
  };
}
