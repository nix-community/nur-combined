{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-megous;
  # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-manjaro;
  # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_latest;

  # alternatively, apply patches directly to stock nixos kernel:
  # boot.kernelPatches = manjaroPatches ++ [
  #   (patchDefconfig kernelConfig)
  # ];

  # configure nixos to build a compressed kernel image, since it doesn't usually do that for aarch64 target.
  # without this i run out of /boot space in < 10 generations
  nixpkgs.hostPlatform.linux-kernel = {
    # defaults:
    name = "aarch64-multiplatform";
    baseConfig = "defconfig";
    DTB = true;
    autoModules = true;
    preferBuiltin = true;
    # extraConfig = ...
    # ^-- raspberry pi stuff: we don't need it.

    # target = "Image";  # <-- default
    target = "Image.gz";  # <-- compress the kernel image
    # target = "zImage";  # <-- confuses other parts of nixos :-(
  };
}
