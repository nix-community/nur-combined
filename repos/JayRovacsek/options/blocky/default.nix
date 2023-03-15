{ config, pkgs, lib, ... }:
let
  cfg = config.services.blocky;

  format = pkgs.formats.yaml { };
  configFile = format.generate "config.yaml" cfg.settings;

  requiredPackages = with pkgs; [ blocky ];
in with lib; {
  options = {
    services.blocky = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc ''
          Blocky, a fast and lightweight DNS proxy as ad-blocker for local network with many features
        '';
      };
      settings = mkOption {
        inherit (format) type;
        default = { };
        description = lib.mdDoc ''
          Blocky configuration. Refer to
          <https://0xerr0r.github.io/blocky/configuration/>
          for details on supported values.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = requiredPackages;
    launchd.user.agents.docker = {

      path = requiredPackages ++ [ config.environment.systemPath ];

      script = "${pkgs.blocky}/bin/blocky --config ${configFile}";

      serviceConfig = {
        Label = "local.blocky";
        AbandonProcessGroup = true;
        RunAtLoad = true;
        ExitTimeOut = 0;
      };
    };
  };
}
