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
  version = "26.3-beta.1";
  tag = "redot-26.3-beta.1";
  hash = "sha256-6RJ4uXMk9ipwxd3N8J1AYNRPnBkteCpaq2dxquPfSgs=";
  inherit withMono;
  nugetDeps = ./deps.json;
}
