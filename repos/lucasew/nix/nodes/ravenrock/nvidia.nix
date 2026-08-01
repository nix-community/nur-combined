{ config, ... }:
{
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidia_x11_legacy470;
  };

  hardware.graphics.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
}
