{ pkgs ? import <nixpkgs> { } }:

rec {
  lib = import ../lib { inherit pkgs; };
  modules = import ../modules;
  overlays = import ../overlays;

  a2ln = pkgs.python3Packages.callPackage ./a2ln { };
  arkenfox-userjs = pkgs.callPackage ./arkenfox-userjs { };
  authentik = pkgs.callPackage ./authentik/package.nix { };
  authentik-outposts = pkgs.recurseIntoAttrs (pkgs.callPackages ./authentik/outposts.nix { inherit authentik; });
  bibata-cursors-tokyonight = pkgs.callPackage ./bibata-cursors-tokyonight { };
  ceserver = pkgs.callPackage ./ceserver { };
  gruvbox-plus-icons = pkgs.callPackage ./gruvbox-plus-icons { };
  hoyolab-daily-bot = pkgs.python3Packages.callPackage ./hoyolab-daily-bot { };
  kes = pkgs.callPackage ./kes { };
  koboldcpp = pkgs.callPackage ./koboldcpp { customtkinter = python3Packages.customtkinter; };
  mpris-ctl = pkgs.callPackage ./mpris-ctl { };
  ocis-bin = pkgs.callPackage ./ocis-bin { };
  proton-ge = pkgs.callPackage ./proton-ge { };
  protonhax = pkgs.callPackage ./protonhax { };
  realrtcw = pkgs.callPackage ./realrtcw { };
  reshade-shaders = pkgs.callPackage ./reshade-shaders { };
  rpcs3 = pkgs.qt6Packages.callPackage ./rpcs3 { };
  seadrive-fuse = pkgs.callPackage ./seadrive-fuse { };
  waydroid-script = pkgs.python3Packages.callPackage ./waydroid-script { };
  wine-ge = pkgs.callPackage ./wine-ge { };

  inherit (pkgs.callPackage ./rosepine-gtk {}) rosepine-gtk-theme rosepine-gtk-icons;
  inherit (pkgs.callPackage ./tokyonight-gtk {}) tokyonight-gtk-theme tokyonight-gtk-icons;
  roundcubePlugins = pkgs.recurseIntoAttrs (pkgs.callPackages ./roundcube-plugins { });
  python3Packages = pkgs.recurseIntoAttrs (pkgs.callPackages ./python3Packages { });
}
