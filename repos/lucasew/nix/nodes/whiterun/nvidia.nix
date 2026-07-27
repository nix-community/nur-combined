{
  self,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ "${self.inputs.nixos-hardware}/common/gpu/nvidia" ];

  services.xserver.videoDrivers = [
    "nvidia"
    "modesetting"
  ];

  boot.blacklistedKernelModules = [ "nvidiafb" "nouveau" "nova_core" ]; # CUDA ou GTFO

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidiaSettings = true;
    open = true;
    # nvidiaPersistenced = true;
  };

  hardware.nvidia-container-toolkit = {
    enable = true;
    device-name-strategy = "uuid";
  };

  virtualisation.docker = {
    # DONT REMOVE THIS LINE, IT'S REQUIRED FOR --gpus=all to work
    enableNvidia = true;
  };

  services.nomad.extraSettingsPlugins = [ pkgs.nomad-driver-nvidia ];
  services.nomad.settings.plugin = lib.mkAfter [
    {
      nomad-device-nvidia = {
        config = {
          enabled = true;
        };
      };
    }
  ];

  environment.systemPackages = with pkgs; [
    nvtopPackages.full
  ];
}
