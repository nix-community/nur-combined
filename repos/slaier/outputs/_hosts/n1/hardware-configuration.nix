{ root, ... }:
{ lib, pkgs, ... }:
{
  imports = with root.nixosModules; [
    phicomm-n1
  ];

  # usb gadget
  hardware.phicomm-n1.dwc2.enable = true;
  boot.kernelModules = [ "g_serial" ];
  systemd.services."serial-getty@".aliases = [ "serial-getty@ttyGS0.service" ];
  services.getty.extraArgs = [ "-w" ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/9055a2e6-e4f6-4cb1-bf0e-606b1f1a88ff";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/6454-42EE";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eth0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlan0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
