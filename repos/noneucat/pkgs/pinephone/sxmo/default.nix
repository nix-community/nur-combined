{ newScope }:

let
  callPackage = newScope self;

  self = rec {
    sxmo-dmenu = callPackage ./sxmo-dmenu.nix { };
    sxmo-dwm = callPackage ./sxmo-dwm.nix { };
    sxmo-st = callPackage ./sxmo-st.nix { };
    sxmo-surf = callPackage ./sxmo-surf.nix { };
    sxmo-svkbd = callPackage ./sxmo-svkbd.nix { };
    sxmo-utils = callPackage ./sxmo-utils.nix { };
    sxmo-xdm-config = callPackage ./sxmo-xdm-config.nix { };

    lisgd = callPackage ./lisgd.nix { };
  };

in self