{ mipmip_pkg, ... }:
{
  extpkg = mipmip_pkg.gnomeExtensions.highlight-focus;
  dconf = {
    name = "org/gnome/shell/extensions/highlight-focus";
    value = {
      border-color="#62a0ea";
      border-radius=9;
      border-width=5;
      keybinding-highlight-now=["<Super>l"];
    };
  };
}

