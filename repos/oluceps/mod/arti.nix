{
  flake.modules.nixos.arti =
    { lib, pkgs, ... }:
    {
      systemd.user.services.arti = {
        wantedBy = [ "default.target" ];
        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.arti} proxy";
          Restart = "always";
        };
      };
    };
}
