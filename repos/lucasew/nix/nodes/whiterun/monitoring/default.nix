{
  config,
  ...
}:
{

  imports = [
    ./node-exporter.nix
    ./zfs.nix
    ./nvidia.nix
  ];

  services.ts-proxy.hosts = {
    prometheus = {
      address = "127.0.0.1:${toString config.services.prometheus.port}";
      enableTLS = true;
    };
  };

  networking.ports.prometheus.enable = true;
  services.prometheus = {
    enable = true;
    inherit (config.networking.ports.prometheus) port;

    webExternalUrl = "http://prometheus.${config.services.ts-proxy.network-domain}";
  };
}
