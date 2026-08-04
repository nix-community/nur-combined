{ lib, pkgs, ... }:

let
  inherit (lib) getExe;
  inherit (pkgs) bash system-sendmail;
in
{
  systemd.services."alert@" = {
    description = "Alert of failed %i";

    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    serviceConfig = {
      SyslogIdentifier = "%p";

      Type = "oneshot";
      ExecStart = ''
        ${getExe bash} -c "${getExe system-sendmail} -i root \
        <<< $'Subject: %H: %i failed\n\n'\"$(systemctl --full status %i)\""
      '';
    };
  };
}
