{
  lib,
  pkgs,
  reIf,
  ...
}:
reIf {

  systemd.services.zeek = {
    description = "Monitor output traffic SNI";
    after = [
      "network.target"
    ];
    requires = [
      "microvm@sept.service"
    ];
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.zeek} -i vm1 ${pkgs.writeText "zeekcfg" ''
        @load policy/tuning/json-logs.zeek
        redef LogAscii::json_timestamps = JSON::TS_ISO8601;
      ''} -C";
      Restart = "always";
      WorkingDirectory = "%L/zeek";
    };

    wantedBy = [ "multi-user.target" ];
  };
}
