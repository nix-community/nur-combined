{ config, pkgs, lib, ... }:
let patchDriver = import ./nvenc-unlock.nix;
in {
  # Required to remedy weird crash when using nvidia in docker
  systemd.enableUnifiedCgroupHierarchy = false;

  hardware = {
    opengl = {
      enable = true;
      driSupport32Bit = true;
    };
    nvidia = {
      package = patchDriver config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}
