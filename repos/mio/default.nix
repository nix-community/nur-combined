# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> {
    config.permittedInsecurePackages = [
      "qtwebengine-5.15.19"
    ];
  },
}:

rec {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # https://github.com/NixOS/nixpkgs/issues/445447
  patch-cmake4 =
    pkg:
    (pkg.overrideAttrs (old: {
      cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
    }));

  telegram-desktop = pkgs.telegram-desktop.overrideAttrs (old: {
    unwrapped = old.unwrapped.overrideAttrs (old2: {
      # see https://github.com/Layerex/telegram-desktop-patches
      patches = (pkgs.telegram-desktop.unwrapped.patches or [ ]) ++ [
        ./patches/0001-telegramPatches.patch
      ];
    });
  });
  materialgram = pkgs.materialgram.overrideAttrs (old: {
    unwrapped = old.unwrapped.overrideAttrs (old2: {
      # see https://github.com/Layerex/telegram-desktop-patches
      patches = (pkgs.materialgram.unwrapped.patches or [ ]) ++ [
        ./patches/0001-materialgramPatches.patch
      ];
    });
  });
  openssh = pkgs.openssh.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./patches/openssh.patch ];
    #doCheck = false;
  });
  openssh_hpn = pkgs.openssh_hpn.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./patches/openssh.patch ];
    #doCheck = false;
  });
  grub2 = pkgs.grub2.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./patches/grub-os-prober-title.patch ];
    #doCheck = false;
    meta = old.meta // {
      broken = pkgs.stdenv.hostPlatform.isDarwin;
    };
  });
  wireguird = pkgs.callPackage ./pkgs/wireguird { };
  example-package = pkgs.callPackage ./pkgs/example-package { };
  lmms = pkgs.callPackage ./pkgs/lmms/package.nix { withOptionals = true; };
  minetest591 = pkgs.callPackage ./pkgs/minetest591 {
  };
  minetest591client = minetest591.override { buildServer = false; };
  minetest591server = minetest591.override { buildClient = false; };
  irrlichtmt = pkgs.callPackage ./pkgs/irrlichtmt {
  };
  minetest580 = pkgs.callPackage ./pkgs/minetest580 {
    irrlichtmt = irrlichtmt;
  };
  minetest580client = minetest580.override { buildServer = false; };
  minetest580-touch = minetest580.override {
    buildServer = false;
    withTouchSupport = true;
  };
  minetest580server = minetest580.override { buildClient = false; };
  musescore3 =
    if pkgs.stdenv.isDarwin then
      pkgs.callPackage ./pkgs/musescore3/darwin.nix { }
    else
      pkgs.libsForQt5.callPackage ./pkgs/musescore3 { };
  zen-browser = pkgs.callPackage ./pkgs/zen-browser/package.nix { };
  tuxguitar = pkgs.tuxguitar.overrideAttrs (old: rec {
    version = "2.0.0beta4";
    src = pkgs.fetchurl {
      url = "https://github.com/helge17/tuxguitar/releases/download/${version}/tuxguitar-${version}-linux-swt-amd64.tar.gz";
      hash = "sha256-QJ8SRY7UBtkICe312O6n8KgbF2MmLpdk2qBseaEUTIc=";
    };
    meta = old.meta // {
      broken = pkgs.stdenv.hostPlatform.isDarwin || pkgs.stdenv.targetPlatform.isAarch64;
    };
  });
  aria2 = pkgs.aria2.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (pkgs.fetchpatch {
        name = "fix patch aria2 fast.patch";
        url = "https://github.com/agalwood/aria2/commit/baf6f1d02f7f8b81cd45578585bdf1152d81f75f.patch";
        sha256 = "sha256-bLGaVJoHuQk9vCbBg2BOG79swJhU/qHgdkmYJNr7rIQ=";
      })
    ];
  });
  audacity4 = pkgs.qt6Packages.callPackage ./pkgs/audacity4/package.nix { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
