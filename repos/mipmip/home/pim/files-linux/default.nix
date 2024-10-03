{
  home.file = {
    ".config/dirty-git.json" = {
      source = ./dirty-git.json;
    };
  };

  home.file = {
    ".bin" = {
      source = ./bin;
      recursive = true;
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
      source = ./Xmodmap;
    };
  };
  home.file = {
    "./.Xresources" = {
      source = ./Xresources;
    };
  };

  home.file = {
    "./.entries.json" = {
      source = ./gnome-shell-custom-menu-entries.json;
    };
  };

  home.file = {
    "./.config/myhotkeys/keys.json" = {
        source = ./myhotkeys.json;
    };
  };

}
