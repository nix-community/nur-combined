{
  lib,
  config,
  ...
}: {
  options = {
    sigprof.hardware.gpu.driver.nvidia.enable =
      lib.mkEnableOption "the proprietary NVIDIA driver";
  };

  config = lib.mkIf config.sigprof.hardware.gpu.driver.nvidia.enable {
    services.xserver.videoDrivers = ["nvidia"];
    sigprof.nixpkgs.permittedUnfreePackages = [
      "nvidia-x11"
      "nvidia-settings"
    ];
  };
}
