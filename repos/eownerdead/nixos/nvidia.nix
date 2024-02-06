{ lib, pkgs, config, ... }:
with lib; {
  options.eownerdead.nvidia = mkEnableOption (mdDoc ''
    EOWNERDEAD recommended settings for NVIDIA graphic cards.
  '');

  config = mkIf config.eownerdead.nvidia {
    services.xserver.videoDrivers = mkDefault [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = mkDefault true;
      powerManagement.enable = mkDefault true;
    };
  };
}

