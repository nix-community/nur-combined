{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.atlas;
in {
  options.services.atlas = {
    enable = mkEnableOption "Atlas service";
  };

  config = mkIf cfg.enable {
    systemd.services.atlas = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = "${pkgs.atlas}/bin/atlas";
    };
  };
}
