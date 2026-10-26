{
  lib,
  pkgs,
  config,
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

  cfg = config.services.rqbit;
in
{
  disabledModules = [ "services/torrent/rqbit.nix" ];
  options.services.rqbit = {
    enable = mkEnableOption "rqbit service";
    package = mkPackageOption pkgs "rqbit" { };
    location = mkOption {
      type = types.str;
    };
  };
  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    users = {
      users.rqbit = {
        group = "rqbit";
        home = "/var/lib/rqbit";
        isSystemUser = true;
      };

      groups = {
        rqbit = {
        };
      };
    };

    networking.firewall.allowedTCPPortRanges = [
      {
        from = 4240;
        to = 4260;
      }
    ];
    networking.firewall.allowedUDPPorts = [
      36741
    ];

    systemd.services.rqbit = {
      wantedBy = [ "multi-user.target" ];
      description = "download daemon";
      serviceConfig = {
        Type = "simple";
        User = "rqbit";
        Group = "rqbit";
        # --socks-url socks5://127.0.0.1:1091
        ExecStart = "${lib.getExe' cfg.package "rqbit"} --http-api-listen-addr [::]:3031 --dht-bootstrap-addrs '87.98.162.88:6881,212.129.33.59:6881,185.157.221.247:25401' server start ${cfg.location}";
        Environment = [ "RUST_LOG=warn" ];
        Restart = "on-failure";
      };
    };
  };
}
