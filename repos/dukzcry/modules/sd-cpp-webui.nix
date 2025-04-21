{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.sd-cpp-webui;
  pkg = pkgs.nur.repos.dukzcry.sd-cpp-webui.override { stable-diffusion-cpp = cfg.package; };
in {
  options.services.sd-cpp-webui = {
    enable = mkEnableOption "sd-cpp-webui service.";
    user = mkOption {
      type = types.str;
      default = "sdcpp";
    };
    group = mkOption {
      type = types.str;
      default = "sdcpp";
    };
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/sd-cpp-webui";
    };
    package = mkOption {
      type = types.package;
      default = pkgs.nur.repos.dukzcry.stable-diffusion-cpp;
    };
  };

  config = mkIf cfg.enable {
    users.users = mkIf (cfg.user == "sdcpp") {
      sdcpp = {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
        createHome = true;
      };
    };
    users.groups = mkIf (cfg.group == "sdcpp") {
      sdcpp = {};
    };
    systemd.services.sd-cpp-webui = {
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${getExe pkg} --listen";
        Restart = "on-failure";
        WorkingDirectory = cfg.dataDir;
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
