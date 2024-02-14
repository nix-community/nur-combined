{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.services.gpg-agent;
in

{
  options.abszero.services.gpg-agent.enable = mkEnableOption "GnuPG private key agent";

  config.services.gpg-agent = mkIf cfg.enable {
    enable = true;
    enableSshSupport = true;
    pinentryFlavor = "gnome3";
  };
}
