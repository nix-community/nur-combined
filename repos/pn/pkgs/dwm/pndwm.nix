{ callPackage }:
let
  pndwm = callPackage ./default.nix {
    patches = [
      ./dwm-systray.diff
      ./dwm-center.diff
      ./dwm-apps.diff
      ./dwm-autostart.diff
    ];
  };
in
  pndwm
