# LOOKING FOR ICONS?
# cd /run/current-system/sw/share/icons/hicolor/scalable/apps


{ config, pkgs, ... }:
{

  xdg.desktopEntries = {

    st = {

      name           = "st";
      comment        = "st suckless terminal";
      genericName    = "st terminal";
      exec           = "st";
      categories     = [
        "TerminalEmulator"
      ];
      terminal       = false;
      startupNotify  = true;
      type           = "Application";
      #icon           = "org.gnome.Console";
      icon           = "ffextra";
      settings       = {
        Keywords = "shell;prompt;command;commandline;cmd;";
        StartupWMClass = "st-256color";
      };
    };

    gvim = {
      name           = "gvim";
      comment        = "Edit text files";
      genericName    = "Text editor";
      exec           = "gvim --remote-tab-silent %F";
      categories     = [
        "Utility"
        "TextEditor"
      ];
      terminal       = false;
      startupNotify  = true;
      type           = "Application";
      icon           = "gvim";
      settings       = {
        Keywords = "Text;editor;";
      };
    };



    firefox-extra = {

      name           = "Firefox Extra";
      comment        = "Extra Firefox with other icon";
      genericName    = "Extra Web Browser";
      exec           = "firefox";
      categories     = [ "Network" ];
      terminal       = false;
      startupNotify  = true;
      type           = "Application";
      icon           = "ffextra";
      settings       = {
        Keywords = "browser;";
        StartupWMClass = "ffextra";
      };
    };

    quiqr-desktop = {

      name           = "Quiqr Desktop";
      comment        = "Quiqr Desktop";
      genericName    = "quiqr desktop";
      exec           = "st";
      categories     = [ "TerminalEmulator" ];
      terminal       = false;
      startupNotify  = true;
      type           = "Application";
      icon           = "org.quiqr.quiqr-desktop";
      settings       = {
        Keywords = "shell;prompt;command;commandline;cmd;";
        StartupWMClass = "quiqr";
      };
    };
  };
}
