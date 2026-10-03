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
  version = "26.3-rc.2";
  tag = "redot-26.3-rc.2";
  hash = "sha256-VMOr1oJ9hUpxpXpD0jOkNI3wcocZw8sjqhN9hO9YlV8=";
  inherit withMono;
  nugetDeps = ./deps.json;
}
