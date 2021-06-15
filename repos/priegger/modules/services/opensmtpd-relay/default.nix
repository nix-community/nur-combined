{ config, lib, pkgs, ... }:

with lib;
let
  host = config.networking.hostName;
  domain = config.networking.domain;

  aliases = pkgs.writeText "aliases" ''
    @ ${cfg.mailTo}
  '';

  serverConfiguration = ''
    table aliases file:${aliases}
    table secrets file:${cfg.authSecretsFile}

    listen on lo

    action "local" mda "${pkgs.procmail}/bin/procmail -f -" virtual <aliases>
    action "relay" relay host "smtp+tls://upstream@${cfg.hostName}" tls auth <secrets> mail-from "${cfg.mailFrom}"
    match for local action "local"
    match for any action "relay"
  '';

  cfg = config.priegger.services.opensmtpd-relay;
in
{
  options.priegger.services.opensmtpd-relay = {
    enable = mkEnableOption "Whether to enable the OpenSMTPD relay.";

    hostName = mkOption {
      type = types.str;
      example = "mail.example.org";
      description = ''
        The host name of the default mail server to use to deliver
        e-mail. Can also contain a port number (ex: mail.example.org:587),
        defaults to port 25 if no port is given.
      '';
    };

    authSecretsFile = mkOption {
      type = types.str;
      example = "/run/keys/opensmtpd-relay-secrets";
      description = ''
        Path to a file that contains the password used for SMTP auth. The file
        should be formatted as follows:
          upstream $username:$password
        See "Credentials table" and "relay context" in: https://man.openbsd.org/table
        This file should be readable by the users that need to execute ssmtp.
      '';
    };

    mailFrom = mkOption {
      type = types.str;
      default = "${host}@${domain}";
      example = "bar@example.org";
      description = ''
        Mail address to send emails from.
      '';
    };

    mailTo = mkOption {
      type = types.str;
      example = "bar@example.org";
      description = ''
        Mail address to forward internal emails to.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.opensmtpd = {
      enable = true;
      inherit serverConfiguration;
    };
  };
}
