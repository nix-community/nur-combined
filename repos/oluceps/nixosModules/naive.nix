{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types mkIf;

  cfg = config.services.naive;
in
{
  options.services.naive = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    package = mkOption {
      type = types.package;
      default = pkgs.emptyDirectory;
    };
  };
  config =
    let
      configFile = config.vaultix.secrets.naive.path;
    in
    mkIf cfg.enable {
      systemd.services.naive = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        description = "naive Daemon";

        serviceConfig = {
          Type = "simple";
          User = "proxy";
          ExecStart = "${lib.getExe cfg.package} ${configFile}";
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
      };
    };
}
