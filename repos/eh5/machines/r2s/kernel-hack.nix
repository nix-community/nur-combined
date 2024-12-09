{
  config,
  pkgs,
  lib,
  ...
}:
let
  kernel_ccache = pkgs.linuxPackages_latest.kernel.override {
    stdenv = pkgs.ccacheStdenv;
    buildPackages = pkgs.buildPackages // {
      stdenv = pkgs.ccacheStdenv;
    };
  };
in
{
  boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor kernel_ccache);

  boot.kernelParams = [
    "dyndbg=\"file gpio-rockchip.c +pf\""
    "dyndbg=\"file pinctrl-rockchip.c +pf\""
  ];

  boot.kernelPatches = [
    {
      name = "hack";
      #patch = ./patch/to/patch.patch;

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

  nixpkgs.overlays = [
    (self: super: {
      ccacheWrapper = super.ccacheWrapper.override {
        extraConfig = ''
          export CCACHE_COMPRESS=1
          export CCACHE_DIR="/nix/var/cache/ccache"
          export CCACHE_SLOPPINESS=random_seed
          export CCACHE_UMASK=007
          if [ ! -d "$CCACHE_DIR" ]; then
            echo "====="
            echo "Directory '$CCACHE_DIR' does not exist"
            echo "Please create it with:"
            echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
            echo "  sudo chown root:nixbld '$CCACHE_DIR'"
            echo "====="
            exit 1
          fi
          if [ ! -w "$CCACHE_DIR" ]; then
            echo "====="
            echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
            echo "Please verify its access permissions"
            echo "====="
            exit 1
          fi
        '';
      };
    })
  ];
}
