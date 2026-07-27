{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.modules.shell.zsh;
in
{
  options.modules.shell.zsh = {
    enable = mkOption {
      default = true;
      description = "Enable zsh profile";
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
    };
  };
}
