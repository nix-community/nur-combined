{ config, lib, ... }:
let
  cfg = config.my.home.xdg;
in
{
  options.my.home.xdg = with lib.my; {
    enable = mkDisableOption "XDG configuration";
  };

  config.xdg = lib.mkIf cfg.enable {
    enable = true;
    # File types
    mime.enable = true;
    # File associatons
    mimeApps = {
      enable = true;
    };
    # User directories
    userDirs = {
      enable = true;
      # I want them lowercased
      desktop = "\$HOME/desktop";
      documents = "\$HOME/documents";
      download = "\$HOME/downloads";
      music = "\$HOME/music";
      pictures = "\$HOME/pictures";
      publicShare = "\$HOME/public";
      templates = "\$HOME/templates";
      videos = "\$HOME/videos";
    };
    # A tidy home is a tidy mind
    dataFile = {
      "bash/.keep".text = "";
      "gdb/.keep".text = "";
      "tig/.keep".text = "";
    };
  };

  # I want a tidier home
  config.home.sessionVariables = with config.xdg; lib.mkIf cfg.enable {
    CARGO_HOME = "${dataHome}/cargo";
    DOCKER_CONFIG = "${configHome}/docker";
    GDBHISTFILE = "${dataHome}/gdb/gdb_history";
    HISTFILE = "${dataHome}/bash/history";
    INPUTRC = "${configHome}/readline/inputrc";
    LESSHISTFILE = "${dataHome}/less/history";
    LESSKEY = "${configHome}/less/lesskey";
  };
}
