{ pkgs, ... }:

{
  systemd.services."alert@" = {
    description = "Alert of failed %I";
    serviceConfig.SyslogIdentifier = "%p";
    serviceConfig.Type = "oneshot";
    serviceConfig.ExecStart = with pkgs; ''
      ${bash}/bin/bash -c "${system-sendmail}/bin/sendmail -i root \
      <<< $'Subject: %I failed\n\n'\"$(systemctl --full status %I)\""
    '';
  };
}
