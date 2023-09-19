{ unstable, ... }:
{
  extpkg = unstable.gnomeExtensions.useless-gaps;
  dconf = {
    name = "org/gnome/shell/extensions/useless-gaps";
    value = {
      gap-size = 25;
      margin-bottom = 25;
      margin-left = 0;
      margin-right = 0;
      margin-top = 0;
      no-gap-when-maximized = false;
    };
  };
}

