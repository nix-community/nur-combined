{ unstable, ... }:
{
  extpkg = unstable.gnomeExtensions.highlight-focus;
  dconf = {
    name = "org/gnome/shell/extensions/highlight-focus";
    value = {
      border-color = "#3584e4";
      border-radius = 9;
      border-width = 6;
    };
  };
}

