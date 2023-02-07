{ config, pkgs, lib, osConfig, ... }:
with pkgs;
let
  # Hack to make home manager module that is linux
  # specific not cause explosions if accidentally loaded onto
  # a non-linux system.
  inherit (lib.strings) hasInfix;
  # TODO: rewrite this garbage
  enable = !(hasInfix "aarch" osConfig.nixpkgs.system)
    && !(hasInfix "darwin" osConfig.nixpkgs.system);
  base = [ dwarf-fortress ];
  mods = with dwarf-fortress-packages; [ dwarf-therapist ];
  themes = with dwarf-fortress-packages; [ ];
  dfPackages = base ++ mods ++ themes;
  cfg = { home.packages = if enable then dfPackages else [ ]; };
in cfg
