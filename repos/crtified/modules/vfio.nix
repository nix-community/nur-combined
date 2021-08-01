{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.virtualisation.vfio;
  acscommit = "1ec4cb0753488353e111496a90bdfbe2a074827e";
in {
  options.virtualisation.vfio = {
    enable = mkEnableOption "VFIO Configuration";
    IOMMUType = mkOption {
      type = types.enum [ "intel" "amd" ];
      example = "intel";
      description = "Type of the IOMMU used";
    };
    devices = mkOption {
      type = types.listOf (types.strMatching "[0-9a-f]{4}:[0-9a-f]{4}");
      default = [ ];
      example = [ "10de:1b80" "10de:10f0" ];
      description = "PCI IDs of devices to bind to vfio-pci";
    };
    disableEFIfb = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "Disables the usage of the EFI framebuffer on boot.";
    };
    blacklistNvidia = mkOption {
      type = types.bool;
      default = false;
      description = "Add Nvidia GPU modules to blacklist";
    };
    ignoreMSRs = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description =
        "Enables or disables kvm guest access to model-specific registers";
    };
    applyACSpatch = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If set, the following things will happen:
          - The ACS override patch is applied
          - Applies the i915-vga-arbiter patch
          - Adds pcie_acs_override=downstream to the command line
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''
      SUBSYSTEM=="vfio", OWNER="root", GROUP="kvm"
    '';

    boot.kernelParams = (if cfg.IOMMUType == "intel" then [
      "intel_iommu=on"
      "intel_iommu=igfx_off"
    ] else
      [ "amd_iommu=on" ]) ++ (optional (builtins.length cfg.devices > 0)
        ("vfio-pci.ids=" + builtins.concatStringsSep "," cfg.devices))
      ++ (optionals cfg.applyACSpatch [
        "pcie_acs_override=downstream,multifunction"
        "pci=nomsi"
      ]) ++ (optional cfg.disableEFIfb "video=efifb:off")
      ++ (optionals cfg.ignoreMSRs [
        "kvm.ignore_msrs=1"
        "kvm.report_ignored_msrs=0"
      ]);

    boot.kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];

    boot.initrd.kernelModules =
      [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
    boot.blacklistedKernelModules =
      optionals cfg.blacklistNvidia [ "nvidia" "nouveau" ];

    boot.kernelPatches = optionals cfg.applyACSpatch [
      {
        name = "add-acs-overrides";
        patch = pkgs.fetchurl {
          name = "add-acs-overrides.patch";
          url =
            "https://raw.githubusercontent.com/slowbro/linux-vfio/v5.5.4-arch1/add-acs-overrides.patch";
          #url =
          #  "https://aur.archlinux.org/cgit/aur.git/plain/add-acs-overrides.patch?h=linux-vfio&id=${acscommit}";
          sha256 = "0nbmc5bwv7pl84l1mfhacvyp8vnzwhar0ahqgckvmzlhgf1n1bii";
        };
      }
      {
        name = "i915-vga-arbiter";
        patch = pkgs.fetchurl {
          name = "i915-vga-arbiter.patch";
          url =
            "https://raw.githubusercontent.com/slowbro/linux-vfio/v5.5.4-arch1/i915-vga-arbiter.patch";
          #url =
          #  "https://aur.archlinux.org/cgit/aur.git/plain/i915-vga-arbiter.patch?h=linux-vfio&id=${acscommit}";
          sha256 = "1m5nn9pfkf685g31y31ip70jv61sblvxgskqn8a0ca60mmr38krk";
        };
      }
    ];
  };
}
