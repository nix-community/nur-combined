{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.direnv;
in

{
  options.abszero.programs.direnv.enable = mkEnableOption "Per-directory environment manager";

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config.global.warn_timeout = "1m";
    };
    home.sessionVariables.DIRENV_LOG_FORMAT = ""; # Disable logging
  };
}
