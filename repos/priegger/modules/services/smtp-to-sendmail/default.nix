{ config, lib, pkgs, ... }:

with lib;
let
  aliases = pkgs.writeText "aliases" ''
    @ nobody
  '';

  configuration = ''
    table aliases file:${aliases}
    listen on lo
    action "local" mda "/run/wrappers/bin/sendmail root" virtual <aliases>
    match for any action "local"
  '';

  # This would lead to an endless loop.
  disableSetSendmail = (if versionAtLeast config.system.nixos.version "20.09" then {
    setSendmail = mkForce false;
  } else {
    addSendmailToSystemPath = mkForce false;
  });

  cfg = config.priegger.services.smtp-to-sendmail;
in
{
  options.priegger.services.smtp-to-sendmail = {
    enable = mkEnableOption "Enable the SMTP to sendmail bridge.";
  };

  config = mkIf cfg.enable {
    services.opensmtpd = {
      enable = true;
      extraServerArgs = [ "-v" ];
      serverConfiguration = configuration;
    } // disableSetSendmail;
  };
}
