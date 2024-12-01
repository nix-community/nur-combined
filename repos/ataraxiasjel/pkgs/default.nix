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

  nurOverlay = final: prev: {
    a2ln = final.python3Packages.callPackage ./a2ln { };
    arkenfox-userjs = final.callPackage ./arkenfox-userjs { };
    authentik = final.callPackage ./authentik/package.nix { };
    authentik-outposts = final.recurseIntoAttrs (final.callPackages ./authentik/outposts.nix { });
    bibata-cursors-tokyonight = final.callPackage ./bibata-cursors-tokyonight { };
    ceserver = final.callPackage ./ceserver { };
    gamma-launcher = final.python3Packages.callPackage ./gamma-launcher { };
    gruvbox-plus-icons = final.callPackage ./gruvbox-plus-icons { };
    hoyolab-claim-bot = final.callPackage ./hoyolab-claim-bot { };
    json-liquid-rs = final.callPackage ./json-liquid-rs { };
    kes = final.callPackage ./kes { };
    koboldcpp = final.callPackage ./koboldcpp { };
    koboldcpp-rocm = final.callPackage ./koboldcpp-rocm { };
    mpris-ctl = final.callPackage ./mpris-ctl { };
    ocis-bin = final.callPackage ./ocis-bin { };
    packwiz = final.callPackage ./packwiz { };
    prometheus-podman-exporter = final.callPackage ./prometheus/podman-exporter.nix { };
    proton-ge = final.callPackage ./proton-ge { };
    protonhax = final.callPackage ./protonhax { };
    realrtcw = final.callPackage ./realrtcw { };
    reshade-shaders = final.callPackage ./reshade-shaders { };
    rpcs3 = final.qt6Packages.callPackage ./rpcs3 { };
    seadrive-fuse = final.callPackage ./seadrive-fuse { };
    superfile = final.callPackage ./superfile { };
    waydroid-script = final.python3Packages.callPackage ./waydroid-script { };
    whoogle-search = final.python3Packages.callPackage ./whoogle-search { };
    wine-ge = final.callPackage ./wine-ge { };
    wopiserver = final.python3Packages.callPackage ./wopiserver { };

    inherit (final.callPackage ./rosepine-gtk { }) rosepine-gtk-theme rosepine-gtk-icons;
    inherit (final.callPackage ./tokyonight-gtk { }) tokyonight-gtk-theme tokyonight-gtk-icons;

    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (
        pyFinal: _pyPrev:
        import ./python3Packages {
          inherit (pyFinal) callPackage;
          inherit lib;
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
