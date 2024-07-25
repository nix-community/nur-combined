{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkDefault;
  cfg = config.abszero.services.gpg-agent;
in

{
  options.abszero.services.gpg-agent.enable = mkEnableOption "GnuPG private key agent";

  config.services.gpg-agent = mkIf cfg.enable {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = mkDefault pkgs.pinentry-gnome3;
  };
}
