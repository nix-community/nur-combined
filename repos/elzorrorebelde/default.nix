##########################################################################
#                                                                        #
#  This file is part of the elzorrorebelde/nur project                   #
#                                                                        #
#  Copyright (C) 2025-2026 Jorge Javier Araya Navarro                    #
#                                                                        #
#  SPDX-License-Identifier: MIT                                          #
#                                                                        #
##########################################################################

{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
  fenixRustPlatform ? null,
}:

let
  # Rustel's Nix build uses this toolchain, independently of the host's Rust.
  rustelRustPlatform =
    if fenixRustPlatform != null then
      fenixRustPlatform
    else
      let
        fenixLock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.fenix.locked;
        fenixSrc = fetchTarball {
          url = "https://github.com/${fenixLock.owner}/${fenixLock.repo}/archive/${fenixLock.rev}.tar.gz";
          sha256 = fenixLock.narHash;
        };
        fenix = import fenixSrc { inherit pkgs system; };
        rustToolchain = fenix.stable.minimalToolchain;
      in
      pkgs.makeRustPlatform {
        cargo = rustToolchain;
        rustc = rustToolchain;
      };
in
{
  abw-abcde = pkgs.callPackage ./packages/abw-abcde { };
  ngpost = pkgs.libsForQt5.callPackage ./packages/ngpost { };
  gtkcsslanguageserver = pkgs.callPackage ./packages/gtk-css-language-server { };
  mkpsxiso = pkgs.callPackage ./packages/mkpsxiso { };
  ppf = pkgs.callPackage ./packages/ppf { };
  tilemolester = pkgs.callPackage ./packages/tilemolester { };

  # rustel - Strudel pattern language engine
  rustel = pkgs.callPackage ./packages/rustel {
    rustPlatform = rustelRustPlatform;
  };

  # Redot Engine
  redot-engine = pkgs.callPackage ./packages/redot-engine { };
  redot-engine-lts = pkgs.callPackage ./packages/redot-engine-lts { };

  # glitch-in-the-herring projects
  bof3-text-extractor = pkgs.callPackage ./packages/bof3-text-extractor { };
  bof4-text-extractor = pkgs.callPackage ./packages/bof4-text-extractor { };
  bof-text-editor = pkgs.python3Packages.callPackage ./packages/bof-text-editor { };
  emi-extractor = pkgs.callPackage ./packages/emi-extractor { };

  # Costa Rica Firma Digital
  firma-digital-cr = pkgs.callPackage ./packages/firma-digital-cr {
    inherit (pkgs) buildFHSEnv;
  };
}
// pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  # Kiri - scrolling tiling KWin script
  kiri = pkgs.kdePackages.callPackage ./packages/kiri {
    inherit (pkgs) kdePackages;
  };
}
