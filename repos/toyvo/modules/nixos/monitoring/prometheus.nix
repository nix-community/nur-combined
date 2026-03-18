{
  config,
  lib,
  ...
}:
{
  options.services.monitoring.prometheus = {
    enable = lib.mkEnableOption "Prometheus server";
  };

  config = lib.mkIf config.services.monitoring.prometheus.enable {
    services.prometheus = {
      enable = true;
      port = 9090;
      retentionTime = "30d";

      extraFlags = [ "--web.enable-remote-write-receiver" ];
    };

    networking.firewall.allowedTCPPorts = [ 9090 ];
  };
}
