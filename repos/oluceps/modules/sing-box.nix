{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
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
      type =
        with types;
        submodule {
          options = {
            enable = mkEnableOption (mdDoc "enable");
            package = mkPackageOptionMD pkgs "metacubexd" { };
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
      default = config.age.secrets.sing.path;
    };
  };
  config = mkIf cfg.enable {
    systemd.services.sing-box =
      {
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        description = "sing-box Daemon";
        serviceConfig = {
          DynamicUser = true;
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
