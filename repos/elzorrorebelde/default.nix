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
}:

rec {
  abw-abcde = pkgs.callPackage ./packages/abw-abcde { };
  ngpost = pkgs.libsForQt5.callPackage ./packages/ngpost { };
  gtkcsslanguageserver = pkgs.callPackage ./packages/gtk-css-language-server { };
  mkpsxiso = pkgs.callPackage ./packages/mkpsxiso { };
  ppf = pkgs.callPackage ./packages/ppf { };
  tilemolester = pkgs.callPackage ./packages/tilemolester { };

  # glitch-in-the-herring projects
  bof3-text-extractor = pkgs.callPackage ./packages/bof3-text-extractor { };
  bof4-text-extractor = pkgs.callPackage ./packages/bof4-text-extractor { };
  bof-text-editor = pkgs.python3Packages.callPackage ./packages/bof-text-editor { };
  emi-extractor = pkgs.callPackage ./packages/emi-extractor { };
}
