{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.direnv;
in

{
  options.abszero.programs.direnv.enable = mkEnableOption "Per-directory environment manager";

  config.programs = mkIf cfg.enable {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config.global.warn_timeout = "1m";
    };
    # Disable logging
    nushell.environmentVariables.DIRENV_LOG_FORMAT = "''";
  };
}
