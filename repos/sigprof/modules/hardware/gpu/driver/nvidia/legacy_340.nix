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

    # In NixOS 23.05 the legacy_340 driver was patched to fix build with 6.1.x
    # kernels (https://github.com/NixOS/nixpkgs/pull/211524); on older NixOS
    # releases the kernel needs to be downgraded to 5.4.x.
    boot.kernelPackages = lib.mkIf (lib.versionOlder config.system.nixos.release "23.05") pkgs.linuxPackages_5_4;

    # Workaround for https://github.com/NixOS/nixpkgs/issues/120602
    hardware.opengl.setLdLibraryPath = true;
  };
}
