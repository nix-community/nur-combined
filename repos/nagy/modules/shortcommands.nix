{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.types) attrsOf listOf str;
  mkShortCommand = (pkgs.callPackage ../lib/shortcommands.nix { }).mkShortCommand;
  cfg = config.nagy.shortcommands;
in
{
  options.nagy.shortcommands = lib.mkOption {
    type = attrsOf (listOf str);
    default = { };
    description = "shortcommands";
  };

  config = {
    environment.systemPackages = lib.mapAttrsToList mkShortCommand cfg;
  };
}
