{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.atlas;
in {
  options.services.atlas = {
    enable = mkEnableOption "Atlas service";
  };

  config = mkIf cfg.enable {
    systemd.services.hello = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = "${pkgs.nur.repos.heph2.atlas}/bin/atlas";
    };
  };
}
