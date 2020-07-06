{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.zsh;
in
{
  options = {
    profiles.zsh = {
      enable = mkOption {
        default = true;
        description = "Enable zsh profile";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
    };
  };
}
