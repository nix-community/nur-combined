{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    sigprof.hardware.gpu.driver.nvidia.legacy_340.enable =
      lib.mkEnableOption "the legacy version 340 of the proprietary NVIDIA driver";
  };

  config = lib.mkIf config.sigprof.hardware.gpu.driver.nvidia.legacy_340.enable {
    sigprof.hardware.gpu.driver.nvidia.enable = true;

    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_340;

    # The legacy 340 driver does not compile against kernels newer than 5.4.x.
    boot.kernelPackages = pkgs.linuxPackages_5_4;

    # Workaround for https://github.com/NixOS/nixpkgs/issues/120602
    hardware.opengl.setLdLibraryPath = true;
  };
}
