{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.services.openssh;
in

{
  options.abszero.services.openssh.enable = mkEnableOption "ssh daemon";

  config.services.openssh = mkIf cfg.enable {
    enable = true;
    startWhenNeeded = true;
    settings.PasswordAuthentication = false;
  };
}
