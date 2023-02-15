{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.services.telegram-sendmail;
in
{
  options = {
    services.telegram-sendmail = {
      enable = mkEnableOption "telegram-sendmail";
    };
  };

  config = mkIf cfg.enable {
    users.users.telegram_sendmail = {
      isSystemUser = true;
      group = "telegram_sendmail";
    };
    users.groups.telegram_sendmail = {};

    sops.secrets.telegram-sendmail = {
      sopsFile = ../../secrets/telegram_sendmail.env;
      owner = config.users.users.telegram_sendmail.name;
      group = config.users.users.telegram_sendmail.group;
      format = "dotenv";
    };

    systemd.services.telegram-sendmail = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        RuntimeDirectory = "telegram-sendmail";
        EnvironmentFile = [ "/var/run/secrets/telegram-sendmail" ];
        User = "telegram_sendmail";
      };
      script = let
        telegram_mail = pkgs.writers.writePython3 "telegram_mail" {flakeIgnore = [ "E265" ]; } (builtins.readFile ../../bin/telegram_mail);
      in ''
        ${telegram_mail} -b "$RUNTIME_DIRECTORY/socket.sock" -n "${config.networking.hostName}"
      '';
    };

    services.mail.sendmailSetuidWrapper = {
      program = "sendmail";
      source = pkgs.writeShellScript "sendmail" ''
        ${pkgs.netcat}/bin/nc -N -U /run/telegram-sendmail/socket.sock
      '';
      setuid = false;
      setgid = false;
      owner = "root";
      group = "root";
    };
  };
}
