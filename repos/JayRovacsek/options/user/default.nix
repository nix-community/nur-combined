{ config, lib, pkgs, ... }:
let
  cfg = config.users.users;
  inherit (config) flake;

  inherit (pkgs) lib;

  inherit (pkgs.stdenv) isLinux;
  inherit (lib.attrsets) filterAttrs;
  inherit (lib.lists) intersectLists;

  linuxUsers = filterAttrs (n: v: v.isNormalUser) cfg;
  darwinUsers = cfg;

  users = if isLinux then linuxUsers else darwinUsers;

  homeManagerModuleDirectory = ../../home-manager-modules;

  local-home-manager-modules =
    builtins.attrNames flake.common.home-manager-modules;

  generatedConfig = builtins.mapAttrs (name: value:
    let
      validModules =
        intersectLists value.home-manager-modules local-home-manager-modules;
    in {
      home-manager.users.${name} =
        builtins.foldl' (acc: x: flake.common.home-manager-modules { }) { }
        validModules;
    }) users;

  config = { home-manager.users = generatedConfig; };

in with lib;
with types; {
  options.users.users = mkOption {
    type = attrsOf (submodule (_: {
      options = {
        home-manager-modules = mkOption {
          type = with types; listOf str;
          default = [ ];
        };
      };
    }));
  };

  inherit config;
}
