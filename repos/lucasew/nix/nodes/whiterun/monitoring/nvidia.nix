{
  config,
  lib,
  pkgs,
  ...
}:

{
  networking.ports.prometheus-exporter-nvidia.enable = true;

  systemd.services.prometheus-nvidia-exporter = {
    script = ''
      exec ${lib.getExe pkgs.unstable.prometheus-nvidia-gpu-exporter} \
        --web.listen-address 127.0.0.1:${toString config.networking.ports.prometheus-exporter-nvidia.port} \
        --nvidia-smi-command /run/current-system/sw/bin/nvidia-smi
    '';
    serviceConfig = {
      PrivateDevices = false;
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.prometheus = {
    scrapeConfigs = [
      {
        job_name = "nvidia";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.networking.ports.prometheus-exporter-nvidia.port}"
            ];
          }
        ];
      }
    ];
  };
}
