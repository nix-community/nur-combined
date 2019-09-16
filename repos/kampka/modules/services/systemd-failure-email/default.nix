{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.kampka.services.systemd-failure-email;

  systemdSendmail = pkgs.writeScriptBin "systemd-email" ''
    #!${pkgs.runtimeShell}

    set -e

    exec ${pkgs.system-sendmail}/bin/sendmail -t $1 <<ERRMAIL
    To: $1
    From: systemd <root@$HOSTNAME>
    Subject: $2
    Content-Transfer-Encoding: 8bit
    Content-Type: text/plain; charset=UTF-8

    $(systemctl status --full "$2")
    ERRMAIL
  '';

in
{

  options.kampka.services.systemd-failure-email = {
    enable = mkEnableOption "systemd-failure-email";

    receipient = mkOption {
      type = types.str;
      default = "root";
      description = "The user or address to receive failure emails.";
    };

    services = mkOption {
      type = types.listOf (types.str);
      default = [];
      description = "A list of services that should generate emails on failure";
    };
  };

  config = mkIf (cfg.enable && cfg.services != []) {

    systemd.services = listToAttrs (
      (
        map (
          service: nameValuePair "systemd-email-${cfg.receipient}-${service}" {
            description = "status email for ${service} to ${cfg.receipient}";

            serviceConfig = {
              ExecStart = "${systemdSendmail}/bin/systemd-email '${cfg.receipient}' '${service}'";
              Type = "oneshot";
              User = "nobody";
              Group = "systemd-journal";
            };
          }
        ) cfg.services
      ) ++ (
        map (
          service: nameValuePair "${service}" {
            unitConfig = {
              OnFailure = "systemd-email-${cfg.receipient}-${service}.service";
            };
          }
        ) cfg.services
      )
    );


  };
}
