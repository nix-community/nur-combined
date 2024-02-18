{ lib, pkgs, ... }:
{
  systemd.user = {
    services.element-web = {
      Install.WantedBy = [ "graphical-session.target" ];
      Unit.PartOf = [ "graphical-session.target" ];
      Unit.After = [ "graphical-session.target" ];
      Service = let element = pkgs.element-web; in {
        ExecStart = "${lib.getBin pkgs.miniserve}/bin/miniserve ${element} -p 9999 --index ${element}/index.html";
      };
    };
  };
}
