# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> {
    #config.permittedInsecurePackages = [
    #  "qtwebengine-5.15.19"
    #];
  },
}:
let
  # TODO: consider -flto , linux only, breaks on darwin
  v3Optimizations =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      pkgs.stdenvAdapters.withCFlags [ "-march=x86-64-v3" ]
    else
      stdenv: stdenv;
  v3overrideAttrs =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      x:
      x.overrideAttrs (old: {
        env.NIX_CFLAGS_COMPILE = "-march=x86-64-v3";
      })
    else
      x: x;
  goV3OverrideAttrs =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      x:
      x.overrideAttrs (old: {
        GOAMD64 = "v3";
      })
    else
      x: x;
  v3override =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      x:
      x.override (prev: {
        stdenv = v3Optimizations pkgs.clangStdenv;
      })
    else
      x:
      x.override (prev: {
        stdenv = pkgs.clangStdenv;
      });
  v3overridegcc =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      x:
      x.override (prev: {
        stdenv = v3Optimizations prev.stdenv;
      })
    else
      x: x;
in
rec {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  telegram-desktop = pkgs.telegram-desktop.overrideAttrs (old: {
    unwrapped = v3overridegcc (
      old.unwrapped.overrideAttrs (old2: {
        # see https://github.com/Layerex/telegram-desktop-patches
        patches = (pkgs.telegram-desktop.unwrapped.patches or [ ]) ++ [
          ./patches/0001-telegramPatches.patch
        ];
      })
    );
  });
  materialgram = pkgs.materialgram.overrideAttrs (old: {
    unwrapped = v3overridegcc (
      old.unwrapped.overrideAttrs (old2: {
        # see https://github.com/Layerex/telegram-desktop-patches
        patches = (pkgs.materialgram.unwrapped.patches or [ ]) ++ [
          ./patches/0001-materialgramPatches.patch
        ];
      })
    );
  });
  openssh = v3override (
    pkgs.openssh.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./patches/openssh.patch ];
      #doCheck = false;
    })
  );
  openssh_hpn = v3override (
    pkgs.openssh_hpn.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./patches/openssh.patch ];
      #doCheck = false;
    })
  );
  grub2 = v3overridegcc (
    pkgs.grub2.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./patches/grub-os-prober-title.patch ];
      #doCheck = false;
      meta = old.meta // {
        broken = pkgs.stdenv.hostPlatform.isDarwin;
      };
    })
  );
  # https://github.com/NixOS/nixpkgs/issues/456347
  sbcl = pkgs.sbcl.overrideAttrs (old: {
    doCheck = false;
  });
  wireguird = goV3OverrideAttrs (pkgs.callPackage ./pkgs/wireguird { });
  lmms = pkgs.callPackage ./pkgs/lmms/package.nix {
    withOptionals = true;
    stdenv = v3Optimizations pkgs.clangStdenv;
  };
  minetest591 = pkgs.callPackage ./pkgs/minetest591 {
    stdenv = v3Optimizations pkgs.clangStdenv;
  };
  minetest591client = minetest591.override { buildServer = false; };
  minetest591server = minetest591.override { buildClient = false; };
  irrlichtmt = pkgs.callPackage ./pkgs/irrlichtmt {
    stdenv = v3Optimizations pkgs.clangStdenv;
  };
  minetest580 = pkgs.callPackage ./pkgs/minetest580 {
    irrlichtmt = irrlichtmt;
    stdenv = v3Optimizations pkgs.clangStdenv;
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
      v3overrideAttrs (pkgs.libsForQt5.callPackage ./pkgs/musescore3 { });
  # https://github.com/musescore/MuseScore/pull/21874
  # https://github.com/adazem009/MuseScore/tree/piano_keyboard_playing_notes
  musescore-adazem009 = v3override (
    pkgs.musescore.overrideAttrs (old: {
      version = "4.4.0-piano_keyboard_playing_notes";
      src = pkgs.fetchFromGitHub {
        owner = "adazem009";
        repo = "MuseScore";
        rev = "e3de9347f6078f170ddbfa6dcb922f72bb7fef88";
        hash = "sha256-1HvwkolmKa317ozprLEpo6v/aNX75sEdaXHlt5Cj6NA=";
      };
      patches = [ ./piano_keyboard_playing_notes.patch ];
    })
  );
  # https://github.com/musescore/MuseScore/pull/28073
  # https://github.com/githubwbp1988/MuseScore/tree/alex
  musescore-alex = v3override (
    pkgs.musescore.overrideAttrs (old: {
      version = "4.6.3-alex-unstable-20251031";
      src = pkgs.fetchFromGitHub {
        owner = "githubwbp1988";
        repo = "MuseScore";
        rev = "487ee2105064f8571f95eb31f03cbf1687e96204";
        hash = "sha256-r2HjHKnO6pD+urrW57z/SPcgm4vSkAMvW4ZJH+c7J4M=";
      };
      patches = [ ];
    })
  );
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
  aria2 =
    (pkgs.aria2.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        (pkgs.fetchpatch {
          name = "fix patch aria2 fast.patch";
          url = "https://github.com/agalwood/aria2/commit/baf6f1d02f7f8b81cd45578585bdf1152d81f75f.patch";
          sha256 = "sha256-bLGaVJoHuQk9vCbBg2BOG79swJhU/qHgdkmYJNr7rIQ=";
        })
      ];
    })).override
      (prev: {
        stdenv = v3Optimizations pkgs.clangStdenv;
      });
  audacity4 = pkgs.qt6Packages.callPackage ./pkgs/audacity4/package.nix { };
  cb = pkgs.callPackage ./pkgs/cb { };
}
