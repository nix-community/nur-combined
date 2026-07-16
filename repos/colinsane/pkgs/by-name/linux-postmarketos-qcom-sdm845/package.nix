# sdm845 kernel, for use by at least Xiaomi Pocophone, tianma panel (maybe others)
# <repo:postmarketOS/pmaports:device/community/device-xiaomi-beryllium/APKBUILD>
# -> `kernal_tianma` is based on `linux-postmarketos-qcom-sdm845`
#   kernel-cmdline.conf:
#   ```
#   console=ttyMSM0,115200
#   # FIXME: Console enabled to workaround a race condition with display initialisation
#   # See https://gitlab.freedesktop.org/drm/msm/-/issues/46
#   -quiet
#   ```
#   modules-initfs.tianma:
#   ```
#   gpi
#   i2c_qcom_geni
#   qcom_pmi8998_charger
#   qcom_fg
#   nt36xxx
#   novatek_nvt_ts
#   ```
#
#   deviceinfo:
#   ```
#   deviceinfo_format_version="0"
#   deviceinfo_name="Xiaomi Poco F1"
#   deviceinfo_manufacturer="Xiaomi"
#   deviceinfo_codename="xiaomi-beryllium"
#   deviceinfo_year="2018"
#   deviceinfo_arch="aarch64"
#   deviceinfo_dtb_tianma="qcom/sdm845-xiaomi-beryllium-tianma"
#   deviceinfo_dtb_ebbg="qcom/sdm845-xiaomi-beryllium-ebbg"
#   deviceinfo_append_dtb="true"
#   deviceinfo_flash_kernel_on_update="true"
#   
#   # Device related
#   deviceinfo_drm="true"
#   deviceinfo_chassis="handset"
#   deviceinfo_external_storage="true"
#   deviceinfo_screen_width="1080"
#   deviceinfo_screen_height="2246"
#   deviceinfo_rootfs_image_sector_size="4096"
#   
#   # Bootloader related
#   deviceinfo_flash_method="fastboot"
#   # FIXME: Console enabled to workaround a race condition with display initialisation
#   # See https://gitlab.freedesktop.org/drm/msm/-/issues/46
#   deviceinfo_generate_bootimg="true"
#   deviceinfo_flash_offset_base="0x00000000"
#   deviceinfo_flash_offset_kernel="0x00008000"
#   deviceinfo_flash_offset_ramdisk="0x01000000"
#   deviceinfo_flash_offset_second="0x00f00000"
#   deviceinfo_flash_offset_tags="0x00000100"
#   deviceinfo_flash_pagesize="4096"
#   deviceinfo_flash_sparse="true"
#   deviceinfo_initfs_compression="zstd:fast"
#   ```

{
  fetchFromGitLab,
  lib,
  linuxManualConfig,
  sane-kernel-tools,
  writeTextFile,
  #VVV nixpkgs calls `.override` on the kernel to configure additional things
  ...
}@args:

let
  extraCallArgs = lib.removeAttrs args [
    "fetchFromGitLab"
    "lib"
    "linuxManualConfig"
    "sane-kernel-tools"
    "writeTextFile"
  ];
  # VVV sources
  # - pmaports.rev: update this first.
  # - src.rev, version: grab from pmaports device/community/linux-postmarketos-qcom-sdm845/APKBUILD
  pmaports = fetchFromGitLab {
    domain = "gitlab.postmarketos.org";
    owner = "postmarketOS";
    repo = "pmaports";
    rev = "2d43d15acf0496c344415d5805a9984fd681e187";
    hash = "sha256-KR00KMZfOeHvYxLeS2RojF0N7nlZTbiNJ1bYs6AkZcc=";
  };
  src = fetchFromGitLab {
    owner = "sdm845-mainline";
    repo = "linux";
    rev = "sdm845-7.1-rc1-r0";
    hash = "sha256-/K74EnSqTkkNJAUe7+g7Rw+aqNVBO5dFyXrSwAKvsdc=";
  };
  version = "7.1.0";
  modDirVersion = "7.1.0-rc1-sdm845";  # or X.Y.Z-rcN; it'll tell you if it's wrong
  # ^^^ sources

  defconfigRaw = builtins.readFile "${pmaports}/device/community/linux-postmarketos-qcom-sdm845/config-postmarketos-qcom-sdm845.aarch64";
  overlayConfig = let
    m = "m";
    y = "y";
  in {
    #
    # extra nixpkgs-specific options
    #
    # for nixos/modules/services/networking/firewall-iptables.nix
    CONFIG_IP_NF_MATCH_RPFILTER = y;
    # for nixos/modules/hardware/all-hardware.nix  (alternatively: CONFIG_COMPILE_TEST=y)
    # CONFIG_BLK_DEV_SD = y;
    # CONFIG_USB_UAS = y;
    # CONFIG_VIRTIO_NET = y;
    CONFIG_TCG_CRB = y;
    CONFIG_TCG_TPM = y;
    CONFIG_TCG_TIS = y;
    CONFIG_CRYPTO_XXHASH = y;
    CONFIG_PCCARD = y;
    CONFIG_PCMCIA = y;
    CONFIG_RASPBERRYPI_FIRMWARE = y;
    CONFIG_BCM2835_MBOX = y;
    CONFIG_ARCH_BCM = y;
    CONFIG_ARCH_BCM2835 = y;
    CONFIG_ARCH_BRCMSTB = y;
    CONFIG_ARCH_ROCKCHIP = y;
    CONFIG_ARCH_SUNXI = y;
    CONFIG_ATA = y;
    CONFIG_ATA_BMDMA = y;
    CONFIG_ATA_PIIX = y;
    CONFIG_ATA_SFF = y;
    CONFIG_AXP20X_ADC = y;
    CONFIG_BATTERY_AXP20X = y;
    CONFIG_BATTERY_PMI8998_FG = y;
    CONFIG_BLK_DEV_3W_XXXX_RAID = y;
    CONFIG_NVME_CORE = y;
    CONFIG_BLK_DEV_NVME = y;
    CONFIG_BLK_DEV_SR = y;
    CONFIG_CHARGER_AXP20X = m;
    CONFIG_DRM_ANALOGIX_ANX6345 = y;
    CONFIG_DRM_ANALOGIX_DP = y;
    CONFIG_DRM_DW_HDMI = y;
    CONFIG_DRM_DW_HDMI_CEC = y;
    CONFIG_DRM_DW_MIPI_DSI = y;
    CONFIG_DRM_ROCKCHIP = y;
    CONFIG_ROCKCHIP_DW_MIPI_DSI = y;
    CONFIG_ROCKCHIP_DW_HDMI = y;
    CONFIG_DRM_SUN4I = y;
    CONFIG_DRM_SUN8I_MIXER = y;
    CONFIG_DRM_VC4 = y;
    CONFIG_FIREWIRE_SBP2 = y;
    CONFIG_FUSION = y;
    CONFIG_FUSION_SPI = y;
    CONFIG_IIO = y;
    CONFIG_MFD_AXP20X = y;
    CONFIG_MFD_AXP20X_I2C = y;
    CONFIG_MMC_SDHCI_PCI = y;
    CONFIG_HAVE_PATA_PLATFORM = y;
    CONFIG_PATA_ALI = y;
    CONFIG_PATA_AMD = y;
    CONFIG_PATA_ARTOP = y;
    CONFIG_PATA_ATIIXP = y;
    CONFIG_PATA_EFAR = y;
    CONFIG_PATA_HPT366 = y;
    CONFIG_PATA_HPT37X = y;
    CONFIG_PATA_HPT3X2N = y;
    CONFIG_PATA_HPT3X3 = y;
    CONFIG_PATA_IT8213 = y;
    CONFIG_PATA_IT821X = y;
    CONFIG_PATA_JMICRON = y;
    CONFIG_PATA_MARVELL = y;
    CONFIG_PATA_MPIIX = y;
    CONFIG_PATA_NETCELL = y;
    CONFIG_PATA_NS87410 = y;
    CONFIG_PATA_OLDPIIX = y;
    CONFIG_PATA_PCMCIA = y;
    CONFIG_PATA_PDC2027X = y;
    CONFIG_PATA_RZ1000 = y;
    CONFIG_PATA_SERVERWORKS = y;
    CONFIG_PATA_SIL680 = y;
    CONFIG_PATA_SIS = y;
    CONFIG_PATA_TRIFLEX = y;
    CONFIG_PATA_VIA = y;
    CONFIG_PATA_WINBOND = y;
    CONFIG_PCIE_BRCMSTB = y;
    CONFIG_PCIE_ROCKCHIP_HOST = y;
    CONFIG_PHY_ROCKCHIP_PCIE = y;
    CONFIG_PINCTRL_AXP209 = y;
    CONFIG_POWER_SUPPLY = y;
    CONFIG_PWM_SUN4I = y;
    CONFIG_REGULATOR_MP8859 = y;
    CONFIG_RESET_RASPBERRYPI = y;
    CONFIG_SATA = y;
    CONFIG_SATA_AHCI = y;
    CONFIG_SATA_INIC162X = y;
    CONFIG_SATA_NV = y;
    CONFIG_SATA_PROMISE = y;
    CONFIG_SATA_QSTOR = y;
    CONFIG_SATA_SIL24 = y;
    CONFIG_SATA_SIL = y;
    CONFIG_SATA_SIS = y;
    CONFIG_SATA_SVW = y;
    CONFIG_SATA_SX4 = y;
    CONFIG_SATA_ULI = y;
    CONFIG_SATA_VIA = y;
    CONFIG_SATA_VITESSE = y;
    CONFIG_SCSI_3W_9XXX = y;
    CONFIG_SCSI_AIC79XX = y;
    CONFIG_SCSI_AIC7XXX = y;
    CONFIG_SCSI_ARCMSR = y;
    CONFIG_SCSI_HPSA = y;
    CONFIG_SCSI_VIRTIO = y;
    CONFIG_USB_XHCI_PCI_RENESAS = y;
    CONFIG_USB_UHCI_HCD = y;
    CONFIG_VIDEO_ROCKCHIP_RGA = y;
    CONFIG_VMXNET3 = y;
    CONFIG_VSOCKETS = y;
    # for nixos/modules/tasks/filesystems/btrfs.nix
    CONFIG_CRYPTO_BLAKE2B = y;
    CONFIG_CRYPTO_CRC32C = y;
    CONFIG_CRYPTO_CRC32 = y;
    # other/from `hosts.moby-smoke.config.boot.initrd.availableKernelModules`
    CONFIG_HID_LENOVO = y;
    CONFIG_FIREWIRE = y;
    CONFIG_FIREWIRE_OHCI = y;
    #
    # extra sane-specific options
    #
    CONFIG_SECURITY_LANDLOCK = y;
    CONFIG_LSM = ''"landlock,lockdown,yama,loadpin,safesetid,selinux,smack,tomoyo,apparmor,bpf"'';
    #
    # "NEW" options (set them to default)
    #
    # CONFIG_GCC_PLUGINS=y
    # CONFIG_GCC_PLUGIN_LATENT_ENTROPY=n
    # CONFIG_VSOCKETS_DIAG=y
    # CONFIG_VSOCKETS_LOOPBACK=y
    # CONFIG_VIRTIO_VSOCKETS=n
    # CONFIG_NVME_MULTIPATH=n
    # CONFIG_NVME_VERBOSE_ERRORS=n
    # CONFIG_NVME_HWMON=n
    # CONFIG_NVME_HOST_AUTH=n
    # CONFIG_SCSI_SAS_ATA=n
    # CONFIG_AIC7XXX_CMDS_PER_DEVICE=32
    # CONFIG_AIC7XXX_RESET_DELAY_MS=8000
    # CONFIG_AIC7XXX_DEBUG_ENABLE=y
    # CONFIG_AIC7XXX_DEBUG_MASK=0
    # CONFIG_AIC7XXX_REG_PRETTY_PRINT=y
    # CONFIG_AIC79XX_CMDS_PER_DEVICE=32
    # CONFIG_AIC79XX_RESET_DELAY_MS=5000
    # CONFIG_AIC79XX_DEBUG_ENABLE=y
    # CONFIG_AIC79XX_DEBUG_MASK=0
    # CONFIG_AIC79XX_REG_PRETTY_PRINT=y
    # CONFIG_SCSI_HISI_SAS=n
    # CONFIG_ATA_VERBOSE_ERROR=y
    # CONFIG_ATA_ACPI=y
    # CONFIG_SATA_ZPODD=n
    # CONFIG_SATA_PMP=y
    # CONFIG_SATA_MOBILE_LPM_POLICY=3
    # CONFIG_SATA_AHCI_PLATFORM=n
    # CONFIG_AHCI_DWC=n
    # CONFIG_AHCI_CEVA=n
    # CONFIG_SATA_ACARD_AHCI=n
    # CONFIG_PDC_ADMA=n
    # CONFIG_SATA_DWC=n
    # CONFIG_SATA_MV=n
    # CONFIG_PATA_ATP867X=n
    # CONFIG_PATA_CMD64X=n
    # CONFIG_PATA_CYPRESS=n
    # CONFIG_PATA_HPT3X3_DMA=n
    # CONFIG_PATA_NINJA32=n
    # CONFIG_PATA_NS87415=n
    # CONFIG_PATA_OPTIDMA=n
    # CONFIG_PATA_PDC_OLD=n
    # CONFIG_PATA_RADISYS=n
    # CONFIG_PATA_RDC=n
    # CONFIG_PATA_SCH=n
    # CONFIG_PATA_TOSHIBA=n
    # CONFIG_PATA_CMD640_PCI=n
    # CONFIG_PATA_OPTI=n
    # CONFIG_PATA_OF_PLATFORM=n
    # CONFIG_PATA_ACPI=n
    # CONFIG_ATA_GENERIC=n
    # CONFIG_PATA_LEGACY=n
    # CONFIG_FUSION_SAS=n
    # CONFIG_FUSION_MAX_SGE=128
    # CONFIG_FUSION_CTL=n
    # CONFIG_FUSION_LOGGING=n
    # CONFIG_SENSORS_DRIVETEMP=n
    # CONFIG_HID_BPF=n
    # CONFIG_MMC_RICOH_MMC=y
    # CONFIG_LEDS_TRIGGER_DISK=n
    # CONFIG_VHOST_VSOCK=n
    # CONFIG_SECURITY_SELINUX=n
    # CONFIG_READABLE_ASM=n
    # CONFIG_DEBUG_SECTION_MISMATCH=n
    # CONFIG_RANDSTRUCT_NONE=y
    # CONFIG_RANDSTRUCT_PERFORMANCE=n
  };
  filteredBase = lib.replaceStrings
    (lib.map (k: "# ${k} is not set") (lib.attrNames overlayConfig) ++ [''CONFIG_LSM="landlock,lockdown,yama,loadpin,safesetid,ipe,bpf"''])
    (lib.map (k: "") (lib.attrNames overlayConfig)                  ++ [""])
    # (lib.map (k: "${k}=m") (lib.attrNames overlayConfig) ++ lib.map (k: "# ${k} is not set") (lib.attrNames overlayConfig))
    # (lib.map (k: "") (lib.attrNames overlayConfig)       ++ lib.map (k: "") (lib.attrNames overlayConfig))
    defconfigRaw;
  defconfigStr =
    filteredBase
    # add options i used in linux-postmarketos-allwinner to get nixos-flavored linux working as expected:
    + lib.foldlAttrs (acc: k: v: "${acc}\n${k}=${v}") "" overlayConfig;

in (linuxManualConfig (extraCallArgs // {
  inherit src version modDirVersion;

  configfile = writeTextFile {
    name = "config-postmarketos-qcom-sdm845.aarch64";
    text = defconfigStr;
  };
  # nixpkgs requires to know the config as an attrset, to do various eval-time assertions.
  # that config is sourced from the pmaports repo, hence this is import-from-derivation.
  # if that causes issues, then copy the config inline to this repo.
  config = sane-kernel-tools.parseDefconfig defconfigStr;
})).overrideAttrs (base: {
  passthru = (base.passthru or {}) // {
    inherit defconfigStr;
    structuredConfig = sane-kernel-tools.parseDefconfigStructuredNonempty defconfigStr;
  };
})

