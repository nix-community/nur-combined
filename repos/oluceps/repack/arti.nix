{
  reIf,
  lib,
  pkgs,
  ...
}:
reIf {
  systemd.user = {
    services = {
      arti = {
        wantedBy = [ "default.target" ];
        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.arti} proxy";
          Restart = "always";
        };
      };
    };
  };
}
