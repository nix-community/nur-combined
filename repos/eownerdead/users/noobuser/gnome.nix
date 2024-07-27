{ pkgs, ... }: {
  home = {
    packages = with pkgs;
      [ gnome.dconf-editor ]
      ++ (with pkgs.gnomeExtensions; [ customize-ibus enhanced-osk ]);
    # HACK: https://github.com/cass00/enhanced-osk-gnome-ext/blob/1921f4cae77bb0694766cfc22a1625e792b24db1/src/extension.js#L476-L477
    sessionVariables.JHBUILD_PREFIX = "${pkgs.gnome.gnome-shell}";
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      show-battery-percentage = true;
    };
    "org/gnome/desktop/input-source" = {
      xkb-options = [ "caps:ctrl_modifier" ]; # caps lock as ctrl
    };
    "org/gnome/nautilus/list-view".use-tree-view = true;
    "org/gnome/nautilus/preferences" = {
      show-create-link = true;
      show-delete-permanently = true;
    };
  };
}
