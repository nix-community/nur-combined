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
  version = "26.3-rc.3";
  tag = "redot-26.3-rc.3";
  hash = "sha256-xHmiUvm+iD1enzIbEVdLTaRcRRGA6p66lQhYYZHL6/U=";
  inherit withMono;
  nugetDeps = ./deps.json;
}
