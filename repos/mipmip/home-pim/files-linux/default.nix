{

  home.file = {
    ".screenlayout" = {
      source = ./.screenlayout;
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
    ".config/awesome" = {
      source = ./awesome;
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
    "./.config/compton.conf" = {
      source = ./compton.conf;
    };
  };
  home.file = {
    "./.config/picom.conf" = {
      source = ./picom.conf;
    };
  };

  home.file = {
    "./.entries.json" = {
      source = ./.entries.json;
    };
  };

  home.file = {
    "./.hotkeys-popup-custom.json" = {
      source = ./.hotkeys-popup-custom.json;
    };
  };

}
