{ lib, mipmip_pkg, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
in

{
  extpkg = mipmip_pkg.gnomeExtensions.search-light;
  dconf = {
    name = "org/gnome/shell/extensions/search-light";
    value = {

      background-color=(mkTuple [ 1.0 1.0 1.0 0.92333334684371948 ]);
      border-color=(mkTuple [0.36400005221366882 0.53479999303817749 0.93333333730697632 1.0]);
      text-color=(mkTuple [0.0 0.0 0.0 1.0]);

      blur-background=true;
      blur-brightness=1.0;
      blur-sigma=200.0;
      border-radius=1.1163793103448276;
      border-thickness=0;
      entry-font-size=1;
      popup-at-cursor-monitor=true;
      scale-height = 0.29999999999999999;
      scale-width=0.31;
      shortcut-search=["<Super>space"];
      show-panel-icon=true;
    };
  };
}

