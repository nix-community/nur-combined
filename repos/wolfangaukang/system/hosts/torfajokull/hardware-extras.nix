{ config, lib, pkgs, ... }:

{
  # Based on nixos-hardware for t430
  boot = {
    blacklistedKernelModules = lib.optionals (!config.hardware.enableRedistributableFirmware) [
      "ath3k"
    ];
    initrd.kernelModules = [ "i915" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
    kernelModules = [ "acpi_call" ];
    kernelParams = [
      "acpi_sleep=nonvs"
      ''acpi_osi="!Windows 2012"''
    ];
  };
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    opengl.extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];
    trackpoint = {
      enable = true;
      emulateWheel = true;
    };
  };
  services = {
    xserver.libinput.enable = lib.mkDefault true;
    tlp.enable = lib.mkDefault ((lib.versionOlder (lib.versions.majorMinor lib.version) "21.05")
                                       || !config.services.power-profiles-daemon.enable);
  };
}
