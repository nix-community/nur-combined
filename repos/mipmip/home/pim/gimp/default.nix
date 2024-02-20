{ config, pkgs, ... }:

## FIND OUT WHICH PACKAGE OF GIMP IS INSTALLED

#let
#
#packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
#
#x = builtins.trace packages;
#
##sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
##formatted = builtins.concatStringsSep "\n" sortedUnique;
#
#in

{
#GIMP SHORTCUTS
  home.file = {
    ".config/GIMP/2.10/menurc" = {
      source = ./menurc;
    };
  };
}


