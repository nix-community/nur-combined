{ pkgs ? import <nixpkgs> { } }:

with pkgs; with lib; rec {
  lib = import ../lib { inherit pkgs; };
  modules = import ../modules;
  overlays = import ../overlays;

  a2ln = python3Packages.callPackage ./a2ln { };
  arkenfox-userjs = callPackage ./arkenfox-userjs { };
  authentik = callPackage ./authentik/package.nix { };
  authentik-outposts = recurseIntoAttrs (callPackages ./authentik/outposts.nix { inherit authentik; });
  bibata-cursors-tokyonight = callPackage ./bibata-cursors-tokyonight { };
  ceserver = callPackage ./ceserver { };
  gruvbox-plus-icons = callPackage ./gruvbox-plus-icons { };
  hoyolab-daily-bot = callPackage ./hoyolab-daily-bot { };
  kes = callPackage ./kes { };
  mpris-ctl = callPackage ./mpris-ctl { };
  ocis-bin = callPackage ./ocis-bin { };
  proton-ge = callPackage ./proton-ge { };
  protonhax = callPackage ./protonhax { };
  realrtcw = callPackage ./realrtcw { };
  reshade-shaders = callPackage ./reshade-shaders { };
  rpcs3 = qt6Packages.callPackage ./rpcs3 { };
  seadrive-fuse = callPackage ./seadrive-fuse { };
  sing-box = callPackage ./sing-box { };
  waydroid-script = callPackage ./waydroid-script { };
  wine-ge = callPackage ./wine-ge { };

  inherit (callPackage ./rosepine-gtk {}) rosepine-gtk-theme rosepine-gtk-icons;
  inherit (callPackage ./tokyonight-gtk {}) tokyonight-gtk-theme tokyonight-gtk-icons;
  roundcubePlugins = dontRecurseIntoAttrs (callPackage ./roundcube-plugins { });
}
