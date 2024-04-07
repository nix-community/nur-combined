{
  self,
  config,
  pkgs,
  ...
}:
{
  imports = [ "${self.inputs.nixos-hardware}/common/gpu/nvidia" ];

  # services.xserver.videoDrivers = [ "modesetting" ]; # usar só AMD pra dar vídeo

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidiaSettings = true;
    # nvidiaPersistenced = true;
  };

  # boot.initrd.kernelModules = [ "nvidia" ];
  # boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  environment.systemPackages = with pkgs; [ nvtop ];
}
