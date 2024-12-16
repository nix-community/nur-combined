{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.sd-cpp-webui;
in {
  options.services.sd-cpp-webui = {
    enable = mkEnableOption "sd-cpp-webui service.";
  };

  config = mkIf cfg.enable {
    systemd.user.services.sd-cpp-webui = {
      wantedBy = [ "default.target" ];

      serviceConfig = {
        ExecStart = "${getExe pkgs.nur.repos.dukzcry.sd-cpp-webui} --listen";
        WorkingDirectory = "%h/.config/sd-cpp-webui";
      };
    };
  };
}
