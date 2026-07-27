{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.hardware.proliant;
in
{
  ##### interface
  options = {
    hardware.proliant = {
      enable = mkEnableOption "Install";

      hardwareDetectionPrograms = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to install programs to investigate the hardware";
      };
    };
  };


  ##### implementation
  config = mkIf cfg.enable {
    # Installs kernel modules and hpssacli command
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
      (pkgs.callPackage ../pkgs/python-ilorest-library.nix {})
      # Newer version than hpssacli installed by HPSmartArray
      (pkgs.callPackage ../pkgs/ssacli.nix {})
      (pkgs.callPackage ../pkgs/ssa.nix {})
      (pkgs.callPackage ../pkgs/ssaducli.nix {})
    ] ++ lib.optionals cfg.hardwareDetectionPrograms [
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
  };
}
