{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.types) attrsOf listOf str;
  inherit (import ../lib/shortcommands.nix { inherit pkgs; }) mkShortCommand;
  cfg = config.nagy.shortcommands;
in
{
  options.nagy.shortcommands = {
    enable = lib.mkEnableOption "shortcommand config";
    commands = lib.mkOption {
      type = attrsOf (listOf str);
      default = { };
      description = "shortcommands";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.mapAttrsToList mkShortCommand cfg.commands;
  };
}
