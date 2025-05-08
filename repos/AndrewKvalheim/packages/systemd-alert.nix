{ lib, pkgs, ... }:

let
  inherit (lib) getExe;
in
{
  systemd.services."alert@" = {
    description = "Alert of failed %I";
    serviceConfig.SyslogIdentifier = "%p";
    serviceConfig.Type = "oneshot";
    serviceConfig.ExecStart = with pkgs; ''
      ${getExe bash} -c "${getExe system-sendmail} -i root \
      <<< $'Subject: %I failed\n\n'\"$(systemctl --full status %I)\""
    '';
  };
}
