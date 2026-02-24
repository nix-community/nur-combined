{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.types) attrsOf listOf str;
  self = import ../. { inherit pkgs; };
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
    environment.systemPackages = lib.mapAttrsToList self.lib.mkShortCommand cfg.commands;
  };
}
