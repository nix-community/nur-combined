{ config, pkgs, lib, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>

    ../modules/ams.nix
  ];

  # Don't start the X server by default.
  # It's annoying if I only want to use it to install
  services.xserver.autorun = lib.mkForce false;

  # Installs kernel modules and hpssacli
  hardware.raid.HPSmartArray.enable = true;

  services.ams.enable = true;

  # Allow HPE proprietary software to be built
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "amsd"
    "hponcfg"
    "hpssacli"
    "ilorest"
    "ssacli"
    "ssa"
    "ssaducli"
  ];

  environment.systemPackages = with pkgs; [
    # HPE Tools
    (pkgs.callPackage ../pkgs/ilorest.nix {})
    (pkgs.callPackage ../pkgs/hponcfg.nix {})
    # Newer version than hpssacli installed by HPSmartArray
    (pkgs.callPackage ../pkgs/ssacli.nix {})
    (pkgs.callPackage ../pkgs/ssa.nix {})
    (pkgs.callPackage ../pkgs/ssaducli.nix {})

    # Hardware detection tools
    pciutils      # lspci
    usbutils      # lsusb
    dmidecode     # For decoding SMBIOS
    smartmontools # For smartctl (S.M.A.R.T)
    nvme-cli      # nvme
    mdadm         # mdadm (MD-RAID)
    lsscsi        # SCSI disks
    hdparm        # SATA disks
    # Misc hw detection tools
    lshw
    hwinfo
  ];

  # Enable console during boot and after for access via iLO vsp
  boot.kernelParams = [
    "console=ttyS0,115200"
  ];
}
