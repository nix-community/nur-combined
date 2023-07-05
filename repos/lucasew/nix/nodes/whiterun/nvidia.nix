{ self, config, pkgs, ... }:
{
  imports = [
    "${self.inputs.nixos-hardware}/common/gpu/nvidia"
  ];

  services.xserver.videoDrivers = [ "modesetting" ]; # usar só AMD pra dar vídeo

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidiaSettings = true;
    # nvidiaPersistenced = true;
  };

  environment.systemPackages = with pkgs; [
    nvtop
  ];
}
