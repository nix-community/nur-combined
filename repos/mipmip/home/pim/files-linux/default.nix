{


  home.file = {
    ".config/git-monitor.json" = {
      source = ./.config/git-monitor.json;
    };
  };

  home.file = {
    ".local/share/icons" = {
      source = ./local-share-icons;
      recursive = true;
    };
  };

  home.file = {
    "./.Xmodmap" = {
      source = ./.Xmodmap;
    };
  };
  home.file = {
    "./.Xresources" = {
      source = ./.Xresources;
    };
  };

  home.file = {
    "./.entries.json" = {
      source = ./.entries.json;
    };
  };

#  home.file = {
#    "./.hotkeys-popup-custom.json" = {
#      source = ./.hotkeys-popup-custom.json;
#    };
#  };

  home.file = {
    "./.hotkeys-custom.json" = {
      source = ./.hotkeys-custom.json;
    };
  };

}
