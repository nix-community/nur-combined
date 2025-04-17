{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
}:
let
  pkgsWithNur = import pkgs.path {
    inherit (pkgs) system;
    config = pkgs.config // {
      allowUnfree = true;
    };
    overlays = pkgs.overlays ++ [ nurOverlay ];
  };
  finalOverlay = nurOverlay pkgsWithNur pkgs;

  nurOverlay =
    final: prev:
    (import ./ocis-bin {
      inherit lib;
      inherit (final) callPackage;
    })
    // {
      a2ln = final.python3Packages.callPackage ./a2ln { };
      arkenfox-userjs = final.callPackage ./arkenfox-userjs { };
      bibata-cursors-tokyonight = final.callPackage ./bibata-cursors-tokyonight { };
      ceserver = final.callPackage ./ceserver { };
      gamma-launcher = final.python3Packages.callPackage ./gamma-launcher { };
      gruvbox-plus-icons = final.callPackage ./gruvbox-plus-icons { };
      hoyolab-claim-bot = final.callPackage ./hoyolab-claim-bot { };
      json-liquid-rs = final.callPackage ./json-liquid-rs { };
      kes = final.callPackage ./kes { };
      koboldcpp-rocm = final.callPackage ./koboldcpp-rocm { };
      mpris-ctl = final.callPackage ./mpris-ctl { };
      prometheus-podman-exporter = final.callPackage ./prometheus/podman-exporter.nix { };
      protonhax = final.callPackage ./protonhax { };
      realrtcw = final.callPackage ./realrtcw { };
      reshade-shaders = final.callPackage ./reshade-shaders { };
      seadrive-fuse = final.callPackage ./seadrive-fuse { };
      syncyomi = final.callPackage ./syncyomi { };
      waydroid-script = final.python3Packages.callPackage ./waydroid-script { };
      whoogle-search = final.python3Packages.callPackage ./whoogle-search { };
      wopiserver = final.python3Packages.callPackage ./wopiserver { };

      inherit (final.callPackage ./rosepine-gtk { }) rosepine-gtk-theme rosepine-gtk-icons;
      inherit (final.callPackage ./tokyonight-gtk { }) tokyonight-gtk-theme tokyonight-gtk-icons;

      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (
          pyFinal: _pyPrev:
          import ./python3Packages {
            inherit (pyFinal) callPackage;
            inherit lib;
            pkgs = final;
          }
        )
      ];
      # expose nur python packages
      python-pkgs = pkgs.recurseIntoAttrs (final.python3Packages.callPackage ./python3Packages { });
    };
in
finalOverlay
// {
  lib = lib.extend (_: _: (pkgs.callPackage ../lib { }));
  modules = import ../modules;
  overlays = import ../overlays;
}
