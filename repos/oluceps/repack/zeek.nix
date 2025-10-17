{
  lib,
  pkgs,
  reIf,
  ...
}:
reIf {

  systemd.services = lib.mapAttrs' (n: v: lib.nameValuePair ("zeek-" + n) v) (
    lib.genAttrs
      [
        "vm1"
        "eno1"
      ]
      (n: {
        description = "Monitor output traffic SNI";
        after = [
          "network.target"
        ];
        requires = [
          "microvm@sept.service"
        ];
        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.zeek} -i ${n} ${pkgs.writeText "zeekcfg" ''
            @load policy/tuning/json-logs.zeek
            redef LogAscii::json_timestamps = JSON::TS_ISO8601;
          ''} -C";
          Restart = "always";
          WorkingDirectory = "%L/zeek/${n}";
        };

        wantedBy = [ "multi-user.target" ];
      })
  );
}
