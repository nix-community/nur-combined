{ unstable, ... }:
{
  extpkg = unstable.gnomeExtensions.favorites-menu;
  dconf = {
    name = "org/gnome/shell/extensions/favorites";
    value = {
      icon = true;
    };
  };
}

