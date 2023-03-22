{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  my.hardware = {
    firmware = {
      cpuFlavor = "intel";
    };
  };

  hardware = {
    trackpoint = {
      enable = true;

      emulateWheel = true; # Holding middle buttons allows scrolling

      device = "TPPS/2 Elan TrackPoint"; # Use the correct device name
    };
  };
}
