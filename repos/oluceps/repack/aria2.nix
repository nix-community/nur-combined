{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    ;

  cfg = config.repack.aria2;
in
{
  options.repack.aria2 = {
  };
  config = mkIf cfg.enable {
    systemd.user.services.aria2 = {
      description = "aria2 Daemon";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.aria2}/bin/aria2c";
        Restart = "on-failure";
      };
    };
  };
}
