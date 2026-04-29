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
}
