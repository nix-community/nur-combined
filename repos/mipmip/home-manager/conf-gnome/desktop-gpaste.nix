{ lib, ... }:

{
  dconf.settings = {

    "org/gnome/GPaste" = {
      history-name = "history";
      show-history = "<Ctrl>space";
      images-support = true;
      primary-to-history = true;
      synchronize-clipboards = true;
      track-changes = true;
      track-extension-state = true;
      trim-items = true;
    };

  };
}
