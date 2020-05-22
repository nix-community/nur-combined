{ config, lib, ... }:

with lib;
let
  cfg = config.profiles.bash;
in
{
  options = {
    profiles.bash = {
      enable = mkOption {
        default = true;
        description = "Enable bash profile and configuration";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      shellAliases = import ./aliases.shell.nix;
    };
  };
}
