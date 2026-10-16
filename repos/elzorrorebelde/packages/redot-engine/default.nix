##########################################################################
#                                                                        #
#  This file is part of the elzorrorebelde/nur project                   #
#                                                                        #
#  Copyright (C) 2026 Jorge Javier Araya Navarro                         #
#                                                                        #
#  SPDX-License-Identifier: MIT                                          #
#                                                                        #
##########################################################################

{
  callPackage,
  withMono ? true
}:

callPackage ./common.nix {
  version = "26.3";
  tag = "redot-26.3-stable";
  hash = "sha256-YSgM0V4dC0HGvS/L+BoWf3Bg+1ZhJyhe4c3/oBazTb0=";
  inherit withMono;
  nugetDeps = ./deps.json;
}
