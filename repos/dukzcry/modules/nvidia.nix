{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.nvidia;
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in {
  options.services.nvidia = {
    enable = mkEnableOption ''
      the Nvidia Optimus support
    '';
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia.prime.offload.enable = true;
    hardware.nvidia.prime.nvidiaBusId = "PCI:1:0:0";
    hardware.nvidia.prime.intelBusId = "PCI:0:2:0";
    # workaround: don't restart xorg on system rebuild
    systemd.services.systemd-udev-trigger.restartIfChanged = false;
    environment = {
      systemPackages = with pkgs; [ nvidia-offload ];
    };
  };
}
