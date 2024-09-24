{ lib, ... }:
with lib.kernel;
{
  LOCALVERSION = freeform "-lantian";
  EXPERT = yes;
  WERROR = no;

  # BBR & CAKE
  TCP_CONG_CUBIC = lib.mkForce module;
  TCP_CONG_BBR = yes;
  DEFAULT_BBR = yes;
  NET_SCH_CAKE = module;

  # Disable unused features
  CRYPTO_842 = no;
  DEBUG_MISC = no;
  DEBUG_PREEMPT = no;
  DEFAULT_SECURITY_APPARMOR = yes;
  GCC_PLUGINS = no;
  HIBERNATION = no;
  KEXEC = no;
  KEXEC_FILE = lib.mkForce no;
  PROVIDE_OHCI1394_DMA_INIT = no;
  SECURITY_SELINUX = no;

  # Fonts
  FONTS = yes;
  FONT_8x16 = yes;

  # Ftrace (for ECC RAM monitoring)
  FTRACE = yes;
  FTRACE_SYSCALLS = yes;

  # HP WMI
  X86_PLATFORM_DRIVERS_HP = yes;

  # i915 PXP (for i915-sriov-dkms)
  DRM_I915_PXP = yes;
  PMIC_OPREGION = yes;

  # Intel SGX
  X86_SGX = yes;

  # IPv6 6RD
  IPV6_SIT_6RD = yes;

  # Ksmbd
  CIFS_SMB_DIRECT = yes;
  CIFS_SWN_UPCALL = yes;
  SMB_SERVER = module;
  SMB_SERVER_CHECK_CAP_NET_ADMIN = yes;
  SMB_SERVER_KERBEROS5 = yes;
  SMB_SERVER_SMBDIRECT = yes;

  # Lockup detector
  LOCKUP_DETECTOR = yes;
  SOFTLOCKUP_DETECTOR = yes;
  HARDLOCKUP_DETECTOR_PERF = yes;
  HARDLOCKUP_DETECTOR = yes;

  # Prefer EXT4 driver
  EXT2_FS = no;
  EXT3_FS = no;
  EXT4_USE_FOR_EXT2 = yes;

  # Prefer EXT4 driver - clear errors
  EXT2_FS_POSIX_ACL = lib.mkForce (option no);
  EXT2_FS_SECURITY = lib.mkForce (option no);
  EXT2_FS_XATTR = lib.mkForce (option no);
  EXT3_FS_POSIX_ACL = lib.mkForce (option no);
  EXT3_FS_SECURITY = lib.mkForce (option no);

  # Reduce log buffer size
  LOG_BUF_SHIFT = freeform "12";
  LOG_CPU_MAX_BUF_SHIFT = freeform "12";

  # Various tunings
  ACPI_APEI = yes;
  ACPI_APEI_GHES = yes;
  ACPI_DPTF = yes;
  ACPI_FPDT = yes;
  ACPI_PCI_SLOT = yes;
  BPF_JIT_ALWAYS_ON = lib.mkForce yes;
  ENERGY_MODEL = yes;
  FAT_DEFAULT_UTF8 = yes;
  FORTIFY_SOURCE = yes;
  FSCACHE_STATS = yes;
  HARDENED_USERCOPY = yes;
  MAGIC_SYSRQ = no;
  NTFS_FS = no;
  PARAVIRT_TIME_ACCOUNTING = yes;
  PM_AUTOSLEEP = yes;
  PSTORE_COMPRESS = yes;
  SHUFFLE_PAGE_ALLOCATOR = yes;
  SLAB_FREELIST_HARDENED = yes;
  SLAB_FREELIST_RANDOM = yes;
  WQ_POWER_EFFICIENT_DEFAULT = yes;

  # Wi-Fi bypass regulatory DB check
  CFG80211_CERTIFICATION_ONUS = yes;
  CFG80211_REG_CELLULAR_HINTS = no;
  CFG80211_REG_RELAX_NO_IR = yes;
  CFG80211_REQUIRE_SIGNED_REGDB = no;

  # ZRAM & Zswap
  ZRAM = module;
  ZRAM_DEF_COMP_ZSTD = yes;
  ZSWAP_COMPRESSOR_DEFAULT_ZSTD = yes;
  ZSWAP_ZPOOL_DEFAULT_ZSMALLOC = yes;
  ZSWAP_DEFAULT_ON = yes;
  ZBUD = lib.mkForce no;
  Z3FOLD = no;
  ZSMALLOC = lib.mkForce yes;

  ################################################################
  # Below are tunes from nixpkgs (xanmod kernel)
  ################################################################

  # Paragon's NTFS3 driver
  NTFS3_FS = module;
  NTFS3_LZX_XPRESS = yes;
  NTFS3_FS_POSIX_ACL = yes;

  # Preemptive Full Tickless Kernel at 1000Hz
  SCHED_CORE = lib.mkForce (lib.mkForce (option no));
  PREEMPT_VOLUNTARY = lib.mkForce no;
  PREEMPT = lib.mkForce yes;
  NO_HZ_FULL = yes;
  HZ_1000 = yes;

  # Futex WAIT_MULTIPLE implementation for Wine / Proton Fsync.
  FUTEX = yes;
  FUTEX_PI = yes;

  # NTSync driver for fast kernel-backed Wine
  NTSYNC = module;
}
