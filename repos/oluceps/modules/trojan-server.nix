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
    mkIf
    optionals
    ;

  cfg = config.services.trojan-server;
in
{
  options.services.trojan-server = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    package = mkOption {
      type = types.package;
      default = pkgs.sing-box;
    };
    configFile = mkOption {
      type = types.str;
      default = config.vaultix.secrets.trojan-server.path;
    };
    openFirewall = mkOption {
      type = types.port;
      default = 7921;
    };
  };
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.openFirewall ];
    networking.firewall.allowedUDPPorts = [ cfg.openFirewall ];
    systemd.services.trojan-server = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      description = "trojan-server Daemon";
      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${lib.getExe' cfg.package "sing-box"} run -c $\{CREDENTIALS_DIRECTORY}/config.json -D $STATE_DIRECTORY";
        LoadCredential =
          [ ("config.json:" + cfg.configFile) ]
          ++ (optionals (!(config ? repack && config.repack.reuse-cert.enable)) [
            "crt:${config.vaultix.secrets."nyaw.cert".path}"
            "key:${config.vaultix.secrets."nyaw.key".path}"
          ]);
        StateDirectory = "trojan-server";
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        Restart = "on-failure";
      };
    };
  };
}
