{config, ...}: {
  # VirtualBox virtualization
  # Note: Incompatible with clang-built kernels (e.g., CachyOS with LTO)
  # If using CachyOS kernel, disable this module
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = ["ac"];

  # VirtualBox kernel modules
  boot.extraModulePackages = [config.boot.kernelPackages.virtualbox];
  boot.kernelModules = ["vboxdrv" "vboxnetflt" "vboxnetadp"];
}
