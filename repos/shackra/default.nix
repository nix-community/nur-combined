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
  ngpost = pkgs.libsForQt5.callPackage ./packages/ngpost { };
  gtkcsslanguageserver = pkgs.callPackage ./packages/gtk-css-language-server { };
  mkpsxiso = pkgs.callPackage ./packages/mkpsxiso { };
}
