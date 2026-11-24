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

callPackage ../redot-engine/common.nix {
  version = "26.2-stable";
  tag = "redot-26.2-stable";
  hash = "sha256-G8BKrgNwOMjuOxrL57VncZqMHqxl0/am3XjdaJjBOgw=";
  inherit withMono;
  nugetDeps = ../redot-engine/deps.json;
}
