{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    mkPackageOption
    mkEnableOption
    mkIf
    ;

  cfg = config.services.sing-box;
in
{
  disabledModules = [ "services/networking/sing-box.nix" ];
  options.services.sing-box = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    webPanel = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "enable";
          package = mkPackageOption pkgs "metacubexd" { };
        };
      };
      default = {
        enable = true;
        package = pkgs.metacubexd;
      };
    };
    package = mkOption {
      type = types.package;
      default = pkgs.sing-box;
    };
    configFile = mkOption {
      type = types.str;
      default = config.vaultix.secrets.sing.path;
    };
  };
  config = mkIf cfg.enable {
    users = {
      users.sing-box = {
        group = "sing-box";
        isSystemUser = true;
      };

      groups.sing-box = { };
    };
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {Add commentMore actions
          if ((action.id == "org.freedesktop.resolve1.set-domains" ||
               action.id == "org.freedesktop.resolve1.set-default-route" ||
               action.id == "org.freedesktop.resolve1.set-dns-servers") &&
              subject.user == "sing-box") {
              return polkit.Result.YES;
          }
      });
    '';

    services.dbus.packages = [ cfg.package ];

    systemd.services.sing-box = {
      # unitConfig.Conflicts = [ "dnsproxy.service" ];
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      description = "sing-box Daemon";
      serviceConfig = {
        User = "sing-box";
        ExecStart = "${lib.getExe' cfg.package "sing-box"} run -c $\{CREDENTIALS_DIRECTORY}/config.json -D $STATE_DIRECTORY";
        LoadCredential = [ ("config.json:" + cfg.configFile) ];
        StateDirectory = "sing";
        CapabilityBoundingSet = [
          "CAP_NET_RAW"
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
        ];
        AmbientCapabilities = [
          "CAP_NET_RAW"
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
        ];
        Restart = "on-failure";
      };
    }
    // lib.optionalAttrs cfg.webPanel.enable {
      preStart = "ln -sfT ${cfg.webPanel.package} $STATE_DIRECTORY/web";
    };
  };
}
