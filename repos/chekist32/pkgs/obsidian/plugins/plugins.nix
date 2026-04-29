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
  obsidian-kanban = mkObsidianPlugin {
    name = "obsidian-kanban";
    version = "2.0.51";
    repo = "https://github.com/obsidian-community/obsidian-kanban";
    mainJsSha256 = "sha256-p+O9TPJfm39TqEHETOmQ2w7195VOvKsXrm3KgDEMOaw=";
    manifestSha256 = "sha256-JJdnhwl+rUZ5aeAUo1ZU56gOTbSal3aJpIr636FeGFQ=";
    stylesCssSha256 = "sha256-7PbdMfFyfEQczm9UeUsNORbc//yH+he4VceboEqF2ac=";
    description = "Create markdown-backed Kanban boards in Obsidian.";
  };
  quickadd = mkObsidianPlugin {
    name = "quickadd";
    version = "2.12.0";
    repo = "https://github.com/chhoumann/quickadd";
    mainJsSha256 = "sha256-4JQDvZ4g/pev/R1TIlugn76tp/XgJN3otkxYkFKb/74=";
    manifestSha256 = "sha256-jquOX5wWMt/waHXHm7VYMqCoL2/s4kbgVyjKvb6CSIk=";
    stylesCssSha256 = "sha256-6CDyjLti9gRyegen3uYUOG52XvPZi8VBrIY85ZYby6I=";
    description = "Quickly add new pages or content to your vault.";
  };
  obsidian-icon-folder = mkObsidianPlugin {
    name = "obsidian-icon-folder";
    version = "2.14.7";
    repo = "https://github.com/FlorianWoelki/obsidian-iconize";
    mainJsSha256 = "sha256-raCwCXBlVsmBAflTpqh/XK/TABCF31k9O+KO7uohggE=";
    manifestSha256 = "sha256-9SShjWnpkKJEFzo1lWgcOaILy8ncGLWa9R5FZg/vXKI=";
    stylesCssSha256 = "sha256-Vv/rg0n0r5fauKFPytywAZ07N7EW16NKoh6VjphFWok=";
    description = "Add icons to anything you desire in Obsidian, including files, folders, and text.";
  };
  obsidian-style-settings = mkObsidianPlugin {
    name = "obsidian-style-settings";
    version = "1.0.9";
    repo = "https://github.com/obsidian-community/obsidian-style-settings";
    mainJsSha256 = "sha256-GCirqs2rTFV4twWmJcWFswUS+O+tTHz8WhjnDMNVdGg=";
    manifestSha256 = "sha256-nP/cIM8qoTVIIOAFC2lLD5tXZEbj1dRKNq6LAYflv7g=";
    stylesCssSha256 = "sha256-7nk30r5QZTqJzLMK5fBXKyNQfVt/EyjQBScaNjB1v9g=";
    description = "Offers controls for adjusting theme, plugin, and snippet CSS variables.";
  };
  card-board = mkObsidianPlugin {
    name = "card-board";
    version = "0.7.9";
    repo = "https://github.com/roovo/obsidian-card-board";
    mainJsSha256 = "sha256-DsqxMp5MGgV+a5515zQcy7w8nih81pClbAHfamwT4jQ=";
    manifestSha256 = "sha256-5A1WYJH3qfpqdUrchBNP+offz7ItZmqKTBH0MeeVdw8=";
    stylesCssSha256 = "sha256-h6KEBb0SQeXe/ObQVzComl8tFSkdbXEB0VD/9TZxvag=";
    description = "Display markdown tasks on kanban style boards.";
  };
}
