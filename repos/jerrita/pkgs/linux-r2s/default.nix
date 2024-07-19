{ stdenv, pkgs, lib, ... }:
pkgs.linux_6_10.override {
  argsOverride = {
    extraMeta = {
      broken = !stdenv.isAarch64;
    };

    defconfig = "rockchip_linux_defconfig";
    kernelPatches = [
      {
        name = "enable-bbr3";
        patch = ../../patches/bbr3.patch;
      }
      {
        name = "rockchip-defconfig";
        patch = ../../patches/rockchip.patch;
      }
      {
        name = "hack";
        patch = null;
        # build reduced kernel to reduce compilation time
        extraStructuredConfig =
          let
            no = lib.mkForce lib.kernel.no;
          in
          {
            EFI_STUB = no;
            EFI = no;
            DRM_ACCEL = no;
            # ACCESSIBILITY = no;
            ACPI = no;
            ATA = no;
            ATM_DRIVERS = no;
            AUXDISPLAY = no;
            # BCMA = no;
            COMEDI = no;
            CXL_BUS = no;
            # DAX = no;
            DCA = no;
            DPLL = no;
            EISA = no;
            EXTCON = no;
            FIREWIRE = no;
            FPGA = no;
            FSI = no;
            DRM = no;
            FB = no;
            HTE = no;
            HYPERV = no;
            IIO = no;
            INFINIBAND = no;
            INTERCONNECT = no;
            IOMMU_SUPPORT = no;
            IPACK_BUS = no;
            ISDN = no;
            MACINTOSH_DRIVERS = no;
            MCB = no;
            MEDIA_SUPPORT = no;
            MEMSTICK = no;
            FUSION = no;
            MOST = no;
            NVME_KEYRING = no;
            NVME_AUTH = no;
            NVME_CORE = no;
            NVME_TARGET = no;
            # DTC = no;
            OF_ALL_DTBS = no;
            PCI = no;
            PCCARD = no;
            PECI = no;
            RAPIDIO = no;
            RAS = no;
            REMOTEPROC = no;
            RPMSG = no;
            SCSI = no;
            STAGING = no;
            USB4 = no;
            VDPA = no;
            XEN = no;
            ZORRO_NAMES = no;
            SOUND = no;
            SND = no;
            VIDEO = no;
            HDMI = no;
          };
      }
    ];
  };
}
