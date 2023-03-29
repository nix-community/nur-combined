{ unstable, ... }:
{
  extpkg = unstable.gnomeExtensions.search-light;
  dconf = {
    name = "org/gnome/shell/extensions/search-light";
    value = {
      blur-background = false;
      blur-brightness = 0.59999999999999998;
      blur-sigma = 30.0;
      border-radius = 1.22;
      border-thickness = 1;
      entry-font-size = 1;
      monitor-count = 1;
      scale-height = 0.29999999999999999;
      scale-width = 0.19;
      shortcut-search= [ "<Super>space "];
      show-panel-icon=false;
    };
  };
}

