{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
  system ? pkgs.system,
}:
let
  pkgsWithNur = import pkgs.path {
    inherit system;
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
      feishin = final.callPackage ./feishin { };
      gamma-launcher = final.python3Packages.callPackage ./gamma-launcher { };
      hoyolab-claim-bot = final.callPackage ./hoyolab-claim-bot { };
      json-liquid-rs = final.callPackage ./json-liquid-rs { };
      kes = final.callPackage ./kes { };
      mpris-ctl = final.callPackage ./mpris-ctl { };
      nix-update-docker-image = final.python3Packages.callPackage ./nix-update-docker-image { };
      prometheus-podman-exporter = final.callPackage ./prometheus/podman-exporter.nix { };
      protonhax = final.callPackage ./protonhax { };
      prts-cursor = final.callPackage ./prts-cursor { };
      realrtcw = final.callPackage ./realrtcw { };
      reshade-shaders = final.callPackage ./reshade-shaders { };
      seadrive-fuse = final.callPackage ./seadrive-fuse { };
      sing-box-beta = final.callPackage ./sing-box/beta.nix { };
      sing-box-extended = final.callPackage ./sing-box/extended.nix { };
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
