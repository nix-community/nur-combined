{
  pkgs,
  source,
  pa,
  gitSupport,
  git,
}:
let
  callPackage = pkgs.lib.callPackageWith (
    pkgs
    // {
      inherit source pa;
    }
  );
in
{
  pa-fuzzel = callPackage ./pa-fuzzel.nix { };
  pa-bemenu = callPackage ./pa-bemenu.nix { };
  pa-wmenu = callPackage ./pa-wmenu.nix { };
  pa-dmenu = callPackage ./pa-dmenu.nix { };
  pa-rofi = callPackage ./pa-rofi.nix { };
  pa-rekey = callPackage ./pa-rekey.nix { };
  pa-pass = callPackage ./pa-pass.nix { inherit gitSupport git; };
}
