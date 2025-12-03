{
  lib,
  linux_latest,
  # linux-postmarketos-pinephonepro,
  #VVV nixpkgs calls `.override` on the kernel to configure additional things, but we don't care about those things
  ...
}:

linux_latest.override {
  # compressed images:
  # - `target = ...` doesn't have effect here.
  # - one _can_ manually gzip the result, and it's about 20% the size, and u-boot boots it *much* faster.
  #   - unsure if u-boot cares about the name of the image (`Image` v.s. `Image.gz`)
  #   - u-boot decompression does not fix size constraints (e.g. >64 MiB decompressed image may still be a problem)
  # target = "Image.gz";  #< this doesn't have effect, have to use manual-config for it
  # DTB = true;  #< this doesn't have effect, but is default

  autoModules = true;
  preferBuiltin = false;
  enableCommonConfig = true;  #< enable nixpkgs config options

  kernelPatches = [
    # {
    #   name = "pmos-config";
    #   patch = null;
    #   structuredExtraConfig = builtins.removeAttrs
    #     linux-postmarketos-pinephonepro.structuredConfig
    #     [
    #       "BASE_SMALL"                    # pmos: =0 ???
    #       "BRIDGE_NETFILTER"              # pmos: =y, but option only supports m
    #       "NFT_COMPAT"                    # pmos: =y, but option only supports m
    #       "NETFILTER_XT_TARGET_CHECKSUM"  # pmos: =y, but option only supports m
    #       "NETFILTER_XT_MATCH_IPVS"       # pmos: =y, but option only supports m
    #       "IP_NF_MATCH_RPFILTER"          # pmos: =y, but option only supports m
    #       "DRM_PANEL_HIMAX_HX8394"        # pmos: =y, but option only supports m
    #       "DRM_PANEL_SIMPLE"              # pmos: =y, but option only supports m
    #       "FSCACHE"                       # pmos: =y, but option only supports m

    #       # these options conflict with nixos defaults
    #       "BINFMT_MISC"                  # pmos:m,    nixpkgs:y
    #       "BPF_JIT_ALWAYS_ON"            # pmos:y,    nixpkgs:n
    #       "CMA_SIZE_MBYTES"              # pmos:256,  nixpkgs:32
    #       "CRYPTO_TEST"                  # pmos:m,    nixpkgs:n
    #       "DEFAULT_MMAP_MIN_ADDR"        # pmos:4096, nixpkgs:32768
    #       "IP_DCCP_CCID3"                # pmos:y,    nixpkgs:n
    #       "IP_NF_TARGET_REDIRECT"        # pmos:y,    nixpkgs:m
    #       "IP_PNP"                       # pmos:y,    nixpkgs:n
    #       "MMC_BLOCK_MINORS"             # pmos:256,  nixpkgs:32
    #       "NET_DROP_MONITOR"             # pmos:m,    nixpkgs:y
    #       "NLS_UTF8"                     # pmos:y,    nixpkgs:m
    #       "NOTIFIER_ERROR_INJECTION"     # pmos:m,    nixpkgs:n
    #       "NR_CPUS"                      # pmos:64,   nixpkgs:384
    #       "PREEMPT"                      # pmos:y,    nixpkgs:n
    #       "STANDALONE"                   # pmos:y,    nixpkgs:n
    #       "TRANSPARENT_HUGEPAGE_ALWAYS"  # pmos:y,    nixpkgs:n
    #       "UEVENT_HELPER"                # pmos:y,    nixpkgs:n
    #       "USB_SERIAL"                   # pmos:m,    nixpkgs:y
    #       "ZSMALLOC"                     # pmos:m,    nixpkgs:y

    #       # these options don't break build, but are nonsensical
    #       "BASE_FULL"
    #       "CC_VERSION_TEXT"
    #       "GCC_VERSION"
    #     ]
    #   ;
    # }
    # {
    #   name = "add-removed";
    #   patch = null;
    #   structuredExtraConfig = with lib.kernel; {
    #     DRM_PANEL_HIMAX_HX8394 = module;
    #     DRM_PANEL_SIMPLE = module;
    #   };
    # }

    {
      # necessary only if `preferBuiltin = false`
      name = "fix-module-only";
      patch = null;
      structuredExtraConfig = with lib.kernel; {
        SUN8I_DE2_CCU = lib.mkForce module;
      };
    }

    # {
    #   name = "upgrade-builtins-to-module";
    #   patch = null;
    #   structuredExtraConfig = with lib.kernel; {
    #     CPU_FREQ_GOV_CONSERVATIVE = yes;
    #     CPUFREQ_DT = yes;
    #     CPUFREQ_DT_PLATDEV = yes;
    #     ARM_SCMI_CPUFREQ = yes;
    #     EFI_VARS_PSTORE = yes;
    #     # MTD = yes;
    #     # MTD_OF_PARTS = yes;
    #     MDIO_DEVICE = yes;
    #     MDIO_BUS = yes;
    #     FWNODE_MDIO = yes;
    #     OF_MDIO = yes;
    #     ACPI_MDIO = yes;
    #     MDIO_DEVRES = yes;
    #     INPUT_LEDS = yes;
    #     INPUT_FF_MEMLESS = yes;
    #     INPUT_RK805_PWRKEY = yes;
    #     SERIAL_8250_DW = yes;
    #     SERIAL_OF_PLATFORM = yes;
    #     I2C_CHARDEV = yes;
    #     I2C_MUX = yes;
    #     I2C_ARB_GPIO_CHALLENGE = yes;
    #     I2C_MUX_GPIO = yes;
    #     I2C_MUX_GPMUX = yes;
    #     I2C_MUX_PINCTRL = yes;
    #     I2C_MUX_REG = yes;
    #     I2C_DEMUX_PINCTRL = yes;
    #     I2C_RK3X = yes;
    #     SPI_ROCKCHIP = yes;
    #     SPI_SPIDEV = yes;
    #     PINCTRL_ROCKCHIP = yes;
    #     PINCTRL_SINGLE = yes;
    #     GPIO_GENERIC_PLATFORM = yes;
    #     GPIO_ROCKCHIP = yes;
    #     IP5XXX_POWER = yes;
    #     CHARGER_GPIO = yes;
    #     # XXX: more
    #   };
    # }
    {
      name = "misc-hw-fixes";
      patch = null;
      structuredExtraConfig = with lib.kernel; {
        # XXX(2024-09-18): megapixels(-next) on OG PP fails to open the camera without this option:
        ARM64_VA_BITS_48 = yes;  #< 48 (not 52) bits for virtual addresses. the other bit widths (ARM64_VA*, ARM64_PA_*, PGTABLE_LEVELS) are then derived/implied same as pmos config
        BACKLIGHT_CLASS_DEVICE = yes;  #< required for display initialization on OG PP (adding "backlight" to initrd does not fix display)
        VIDEO_SUNXI = yes;  #< VIDEO_SUNXI defaults to `n` since the driver is in staging (as of 2024-09-26)
      };
    }
    # {
    #   name = "reset-nixpkgs-overrides";
    #   patch = null;
    #   structuredExtraConfig = with lib.kernel; {
    #     # this is required for boot (but why??)
    #     ACPI_FPDT = lib.mkForce no;

    #     # this is required for boot (but why??)
    #     SHUFFLE_PAGE_ALLOCATOR = lib.mkForce no;

    #     # this is required for boot (but autoModules gets that for us)
    #     # TRANSPARENT_HUGEPAGE_ALWAYS = lib.mkForce yes;

    #     # this is required for boot
    #     SYSFB_SIMPLEFB = lib.mkForce no;

    #     # this is required for boot (but why??)
    #     IO_STRICT_DEVMEM = no;

    #     # this is required for boot (but why??)
    #     PRINTK_INDEX = lib.mkForce no;

    #     # this is required for boot (but why??)
    #     CRASH_RESERVE = yes;

    #     # this is required for boot (but why??)
    #     PREEMPT = lib.mkForce yes;
    #     # this is required for boot (but why??)
    #     PREEMPT_VOLUNTARY_BUILD = no;

    #     # this is required for boot (but why??)
    #     MMC_BLOCK_MINORS = lib.mkForce (freeform "256");

    #     # this is required for boot (but why??)
    #     MEDIA_PCI_SUPPORT = lib.mkForce no;
    #   };
    # }

    # {
    #   # i suspect that u-boot can only load a (decompressed) image up to 64 MiB in size for this platform.
    #   # i say that because `CONFIG_DEBUG_INFO=y` seemed to break the boot,
    #   #   when it took size from 62843392B -> 71297536B
    #   #
    #   # see: <repo:u-boot/u-boot:include/configs/rk3399_common.h>
    #   # - fdt_addr_r         = 0x01e00000
    #   # - fdtoverlay_addr_r  = 0x01f00000
    #   # - kernel_addr_r      = 0x02080000
    #   # - ramdisk_addr_r     = 0x06000000
    #   # - kernel_comp_addr_r = 0x08000000
    #   # - kernel_comp_size   = 0x02000000
    #   # to avoid overlapping the ramdisk, the kernel must be smaller than 0x06000000 - 0x02080000 = 0x3f80000 = 63.5 MiB = 66584576B
    #   # this is possibly adjustable via `/boot/ubootefi.var`? or embedding u-boot directives in extlinux.conf?
    #   #
    #   # largest observed bootable image: 63300096B
    #   # smallest observed non-bootable image: 71297536B
    #   name = "optimize-for-size";
    #   patch = null;
    #   structuredExtraConfig = with lib.kernel; {
    #     CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE = no;
    #     CONFIG_CC_OPTIMIZE_FOR_SIZE = yes;

    #     DEBUG_KERNEL = lib.mkForce no;  #< TODO: something re-enabled this...
    #     # DEBUG_FS = no;
    #     # DEBUG_FS_ALLOW_ALL = no;
    #     DEBUG_MISC = no;
    #     DEBUG_INFO_NONE = yes;
    #     DEBUG_INFO = no;
    #     DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT = lib.mkForce no;
    #     DEBUG_INFO_BTF = lib.mkForce no;  # BPF debug symbols. rec by <https://nixos.wiki/wiki/Linux_kernel#Too_high_ram_usage>
    #     DEBUG_LIST = lib.mkForce no;
    #     # GPIO_VIRTUSER = no;
    #     DYNAMIC_DEBUG = lib.mkForce no;
    #     # PM_ADVANCED_DEBUG = lib.mkForce no;
    #     SCHED_DEBUG = lib.mkForce no;
    #     SLUB_DEBUG = no;
    #     SUNRPC_DEBUG = lib.mkForce no;

    #     # these particular options bloat the kernel and are almost *surely* unused.
    #     CORESIGHT = no;  #< CPU tracing
    #     COMEDI = no;  #< data acquisition devices
    #     DAMON = lib.mkForce no;  #< perf-based monitoring, to see how frequently different memory regions are accessed
    #     DRM_AMDGPU = no;
    #     DRM_NOUVEAU = no;
    #     DRM_RADEON = no;
    #     DRM_XE = no;   #< intel graphics
    #     DVB_CORE  = no;  #< digial video (tuners)
    #     # FPGA = no;
    #     INFINIBAND = lib.mkForce no;  #< networking protocol
    #     IWLWIFI = no;  #< intel wireless
    #     MEDIA_ANALOG_TV_SUPPORT = lib.mkForce no;
    #     MEDIA_DIGITAL_TV_SUPPORT = lib.mkForce no;
    #     MEDIA_RADIO_SUPPORT = no;  # AM/FM tuners
    #     MEDIA_SDR_SUPPORT = no;  # without this, `CONFIG_MEDIA_TUNER` spontaneously re-appears...
    #     MEDIA_TUNER = no;
    #     # NET_VENDOR_INTEL = no;  # TODO: does this impact e.g. USB-eth adapters?
    #     SPEAKUP = no;  #< text to speech

    #     PCI = no;
    #     # SCSI = no;  #< USB_STORAGE depends on SCSI?...

    #     # net stuff, disabled as much to save space as to be hardened
    #     DNS_RESOLVER = no;
    #     MPLS = no;  # "MultiProtocol Label Switching"
    #     OPENVSWITCH = no;
    #     TLS = lib.mkForce no;  #< TLS can be done in userspace (and more safely)
    #     # weird networking protocols nothing on my PCs are going to be using:
    #     ATM = no;
    #     IP_VS = no;  #< weird load balancing thing for server farms
    #     LAPB = no;
    #     RDS = no;  # "Reliable Datagram Sockets Protocol"
    #     TIPC = no;  # "Transparent Inter Process Communication" (net proto)
    #     X25 = no;
    #   };
    # }

    # {
    #   name = "reset-automodules-overrides";
    #   patch = null;
    #   structuredExtraConfig = with lib.kernel; {
    #     # NR_CPUS = lib.mkForce (freeform "64");
    #     # RANDOM_KMALLOC_CACHES = lib.mkForce no;
    #     # HOTPLUG_PCI_PCIE = lib.mkForce no;
    #     # DRM_ACCEL = lib.mkForce no;
    #     # KFENCE = lib.mkForce no;

    #     BLK_INLINE_ENCRYPTION = lib.mkForce no;

    #     CRASH_DUMP = lib.mkForce yes;
    #     PREEMPTION = yes;
    #     PREEMPT_BUILD = yes;
    #     PREEMPT_COUNT = yes;
    #     PREEMPT_RCU = yes;

    #     RUNTIME_TESTING_MENU = lib.mkForce yes;

    #     # TODO: one of  these is required for boot?
    #     BT_HCIUART_BCSP = lib.mkForce no;
    #     DRM_NOUVEAU_GSP_DEFAULT = lib.mkForce no;
    #     PINCTRL_AMD = lib.mkForce no;

    #     # TODO: at least one of these is required for boot
    #     NO_HZ_IDLE = yes;
    #     NO_HZ_FULL = lib.mkForce no;
    #     # CONTEXT_TRACKING_USER = no;
    #     TICK_CPU_ACCOUNTING = yes;
    #     VIRT_CPU_ACCOUNTING = no;
    #     TASKS_RCU = yes;
    #     STANDALONE = lib.mkForce yes;

    #     # TODO: one of these is required for boot?
    #     ATH10K_DFS_CERTIFIED = lib.mkForce no;
    #     CHROMEOS_TBMC = lib.mkForce no;
    #     MOUSE_ELAN_I2C_SMBUS = lib.mkForce no;
    #     XFRM_ESPINTCP = no;

    #     # AUXDISPLAY = lib.mkForce no;
    #     # DRM_DISPLAY_DP_AUX_CEC = lib.mkForce no;
    #     # DRM_DISPLAY_DP_AUX_CHARDEV = lib.mkForce no;
    #     # DRM_VC4_HDMI_CEC = lib.mkForce no;

    #     # TODO: one of these is required for boot?
    #     SLAB_BUCKETS = lib.mkForce no;
    #     DEFAULT_MMAP_MIN_ADDR = lib.mkForce (freeform "4096");
    #     TRANSPARENT_HUGEPAGE_MADVISE = lib.mkForce no;
    #     ZONE_DEVICE = lib.mkForce no;
    #     UEVENT_HELPER = lib.mkForce yes;
    #     LOGO = lib.mkForce yes;
    #     LOGO_LINUX_CLUT224 = yes;
    #     POWERCAP = lib.mkForce no;
    #     # CPUMASK_OFFSTACK = no;
    #     # or maybe this?
    #     HID_BPF = lib.mkForce no;

    #     # TODO: one of these is required for boot?
    #     USB_SERIAL = lib.mkForce module;
    #     FSL_MC_UAPI_SUPPORT = lib.mkForce no;
    #     NET_FC = lib.mkForce no;
    #     NET_VENDOR_MEDIATEK = lib.mkForce no;
    #     WAN = lib.mkForce no;
    #     # or maybe one of these?
    #     HARDLOCKUP_DETECTOR = lib.mkForce no;
    #     U_SERIAL_CONSOLE = lib.mkForce no;
    #     WATCH_QUEUE = lib.mkForce no;
    #     SCHED_CORE = lib.mkForce no;
    #     BPF_JIT_ALWAYS_ON = lib.mkForce yes;
    #     PARAVIRT_TIME_ACCOUNTING = lib.mkForce no;
    #     ARCH_HAS_GENERIC_CRASHKERNEL_RESERVATION = yes;  #< does not take effect
    #     COMPAT_ALIGNMENT_FIXUPS = lib.mkForce no;
    #     IDLE_PAGE_TRACKING = lib.mkForce no;
    #     PAGE_IDLE_FLAG = no;
    #     EFI_ZBOOT = lib.mkForce no;
    #     ZRAM_MULTI_COMP = lib.mkForce no;

    #     # upgrade `m` -> `y`
    #     # INPUT_MATRIXKMAP = lib.mkForce yes;
    #     # I2C_CROS_EC_TUNNEL = yes;
    #     # CHARGER_CROS_PCHG = yes;
    #     # CHARGER_CROS_CONTROL = yes;
    #     # SENSORS_CROS_EC = yes;
    #     # MFD_CROS_EC_DEV = yes;
    #     # REGULATOR_CROS_EC = yes;
    #     # RTC_DRV_CROS_EC = yes;
    #     # CROS_EC = lib.mkForce yes;
    #     # CROS_EC_I2C = lib.mkForce yes;
    #     # CROS_EC_SPI = lib.mkForce yes;
    #     # EXTCON_USBC_CROS_EC = yes;

    #     # TODO: at least one of these is required for boot
    #     # UNINLINE_SPIN_UNLOCK = yes;  #< DOESN'T TAKE EFFECT
    #     # CMA_SIZE_MBYTES = lib.mkForce (freeform "256");
    #     SOFTLOCKUP_DETECTOR_INTR_STORM = no;
    #     LDM_PARTITION = lib.mkForce no;
    #     DAMON = lib.mkForce no;
    #     SKB_DECRYPTED = no;  #< does not take effect
    #     CFG80211_CERTIFICATION_ONUS = lib.mkForce no;
    #     MAC80211_DEBUGFS = lib.mkForce no;
    #     SOCK_VALIDATE_XMIT = no;  #< does not take effect
    #     ACCESSIBILITY = lib.mkForce no;
    #     VIRTIO_MMIO_CMDLINE_DEVICES = lib.mkForce no;
    #     DEBUG_INFO = no;
    #     SCHED_DEBUG = lib.mkForce no;
    #     FUNCTION_PROFILER = lib.mkForce no;
    #     SCHED_TRACER = lib.mkForce no;
    #     DEBUG_INFO_NONE = yes;
    #     TLS = lib.mkForce no;
    #     XDP_SOCKETS_DIAG = lib.mkForce no;
    #     IP_PNP = lib.mkForce yes;
    #     # IP_PNP_DHCP = yes;
    #     # IP_PNP_BOOTP = yes;
    #     IP_DCCP_CCID3 = lib.mkForce yes;
    #     # IP_DCCP_TFRC_LIB = yes;
    #     RTW88 = lib.mkForce no;
    #     MEDIA_CEC_RC = lib.mkForce no;
    #     CRYPTO_TEST = lib.mkForce module;
    #     PROC_VMCORE = yes;  #< does not take effect ??
    #     # or maybe it's one of these?
    #     FUSION = lib.mkForce no;
    #     HIPPI = lib.mkForce no;
    #     BRCMFMAC_PCIE = lib.mkForce no;
    #     MOUSE_PS2_ELANTECH = lib.mkForce no;
    #     INFINIBAND = lib.mkForce no;
    #   };
    # }

    # {
    #   # i'd like to patch some drivers, and that's easier to do when i build them for out-of-tree.
    #   # i can't even set these to `=m`, because then nixpkgs `system.modulesTree` will complain
    #   # about conflicting kernel modules (in tree + out-of-tree).
    #   # so just don't build these here, and rely wholly on my out-of-tree modules.
    #   name = "make-module-for-out-of-tree";
    #   patch = null;
    #   structuredExtraConfig = with lib.kernel; {
    #     # MFD_RK8XX = no;
    #     # MFD_RK8XX_I2C = no;
    #     # MFD_RK8XX_SPI = no;  #< necessary for MFD_RK8XX=... to apply
    #     MFD_RK8XX = module;
    #     MFD_RK8XX_I2C = module;
    #     MFD_RK8XX_SPI = module;
    #   };
    # }
  ];
}
