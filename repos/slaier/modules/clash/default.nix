# Modified version of clash module based on LEXUGE's
{ pkgs, config, lib, ... }:

with lib;

let
  inherit (lib) optionalString mkIf;
  cfg = config.slaier.services.clash;
  inherit (cfg) clashUserName;

  yacd = pkgs.fetchzip {
    url = "https://github.com/haishanh/yacd/releases/download/v0.3.7/yacd.tar.xz";
    sha256 = "sha256-nuDyFXwzpE9Wb56VL8472SBX0yzv9joDudVyjDc44E4=";
  };

  maxmind-geoip = pkgs.fetchurl {
    url = "https://github.com/Dreamacro/maxmind-geoip/releases/download/20220912/Country.mmdb";
    sha256 = "sha256-YIQjuWbizheEE9kgL+hBS1GAGf2PbpaW5mu/lim9Q9A=";
  };

  clashModule = types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Clash transparent proxy module.";
      };

      dashboard.port = mkOption {
        type = types.port;
        default = 3333;
        description = "Port for YACD dashboard to listen on.";
      };

      clashUserName = mkOption {
        type = types.str;
        default = "clash";
        description =
          "The user who would run the clash proxy systemd service. User would be created automatically.";
      };

      afterUnits = mkOption {
        type = with types; listOf str;
        default = [ ];
        description =
          "List of systemd units that need to be started after clash. Note this is placed in `before` parameter of clash's systemd config.";
      };

      requireUnits = mkOption {
        type = with types; listOf str;
        default = [ ];
        description =
          "List of systemd units that need to be required by clash.";
      };

      beforeUnits = mkOption {
        type = with types; listOf str;
        default = [ ];
        description =
          "List of systemd units that need to be started before clash. Note this is placed in `after` parameter of clash's systemd config.";
      };
    };
  };
in
{
  options.slaier.services.clash = mkOption {
    type = clashModule;
    default = { };
    description = "Clash system service related configurations";
  };

  config = mkIf (cfg.enable) {
    environment.etc."clash/Country.mmdb".source = "${maxmind-geoip}";

    # Yacd
    services.lighttpd = {
      enable = true;
      port = cfg.dashboard.port;
      document-root = "${yacd}";
    };

    users.users.${clashUserName} = {
      description = "Clash deamon user";
      isSystemUser = true;
      group = "clash";
    };
    users.groups.clash = { };

    systemd.services.clash = {
      path = with pkgs; [ clash ];
      description = "Clash networking service";
      after = [ "network.target" ] ++ cfg.beforeUnits;
      before = cfg.afterUnits;
      requires = cfg.requireUnits;
      wantedBy = [ "multi-user.target" ];
      script =
        "exec clash -d /etc/clash"; # We don't need to worry about whether /etc/clash is reachable in Live CD or not. Since it would never be execuated inside LiveCD.

      # Don't start if the config file doesn't exist.
      unitConfig = {
        # NOTE: configPath is for the original config which is linked to the following path.
        ConditionPathExists = "/etc/clash/config.yaml";
      };
      serviceConfig = {
        # CAP_NET_BIND_SERVICE: Bind arbitary ports by unprivileged user.
        # CAP_NET_ADMIN: Listen on UDP.
        AmbientCapabilities =
          "CAP_NET_BIND_SERVICE CAP_NET_ADMIN"; # We want additional capabilities upon a unprivileged user.
        User = clashUserName;
        Restart = "on-failure";
      };
    };
  };
}
