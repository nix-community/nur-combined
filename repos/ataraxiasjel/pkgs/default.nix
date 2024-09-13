{
  pkgs ? import <nixpkgs> { },
}:

rec {
  lib = import ../lib { inherit pkgs; };
  modules = import ../modules;
  overlays = import ../overlays;

  a2ln = pkgs.python3Packages.callPackage ./a2ln { };
  arkenfox-userjs = pkgs.callPackage ./arkenfox-userjs { };
  authentik = pkgs.callPackage ./authentik/package.nix { };
  authentik-outposts = pkgs.recurseIntoAttrs (pkgs.callPackages ./authentik/outposts.nix { });
  bibata-cursors-tokyonight = pkgs.callPackage ./bibata-cursors-tokyonight { };
  ceserver = pkgs.callPackage ./ceserver { };
  gruvbox-plus-icons = pkgs.callPackage ./gruvbox-plus-icons { };
  hoyolab-claim-bot = pkgs.callPackage ./hoyolab-claim-bot { };
  json-liquid-rs = pkgs.callPackage ./json-liquid-rs { };
  kes = pkgs.callPackage ./kes { };
  koboldcpp = pkgs.callPackage ./koboldcpp { inherit (python-pkgs) customtkinter; };
  koboldcpp-rocm = pkgs.callPackage ./koboldcpp-rocm { inherit (python-pkgs) customtkinter; };
  mpris-ctl = pkgs.callPackage ./mpris-ctl { };
  ocis-bin = pkgs.callPackage ./ocis-bin { };
  packwiz = pkgs.callPackage ./packwiz { };
  prometheus-podman-exporter = pkgs.callPackage ./prometheus/podman-exporter.nix { };
  proton-ge = pkgs.callPackage ./proton-ge { };
  protonhax = pkgs.callPackage ./protonhax { };
  realrtcw = pkgs.callPackage ./realrtcw { };
  reshade-shaders = pkgs.callPackage ./reshade-shaders { };
  rpcs3 = pkgs.qt6Packages.callPackage ./rpcs3 { };
  seadrive-fuse = pkgs.callPackage ./seadrive-fuse { };
  superfile = pkgs.callPackage ./superfile { };
  waydroid-script = pkgs.python3Packages.callPackage ./waydroid-script { };
  whoogle-search = pkgs.python3Packages.callPackage ./whoogle-search { };
  wine-ge = pkgs.callPackage ./wine-ge { };
  wopiserver = pkgs.python3Packages.callPackage ./wopiserver { inherit (python-pkgs) cs3apis; };

  inherit (pkgs.callPackage ./rosepine-gtk { }) rosepine-gtk-theme rosepine-gtk-icons;
  inherit (pkgs.callPackage ./tokyonight-gtk { }) tokyonight-gtk-theme tokyonight-gtk-icons;
  python-pkgs = pkgs.recurseIntoAttrs (pkgs.python3Packages.callPackage ./python3Packages { });
}
