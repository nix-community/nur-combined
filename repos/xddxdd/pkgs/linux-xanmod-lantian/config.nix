{ lib, ... }:

with lib.kernel;
{
  LOCALVERSION = freeform "-lantian";
  EXPERT = yes;

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
  FTRACE = lib.mkForce no;
  GCC_PLUGINS = no;
  HIBERNATION = no;
  KEXEC = no;
  KEXEC_FILE = lib.mkForce no;
  PROVIDE_OHCI1394_DMA_INIT = no;
  SECURITY_SELINUX = no;
  STACKTRACE = no;
  X86_SGX = lib.mkForce no;

  # Disable unused features - clear errors
  BPF_EVENTS = lib.mkForce (option no);
  FTRACE_SYSCALLS = lib.mkForce (option no);
  FUNCTION_PROFILER = lib.mkForce (option no);
  FUNCTION_TRACER = lib.mkForce (option no);
  NET_DROP_MONITOR = lib.mkForce (option no);
  RING_BUFFER_BENCHMARK = lib.mkForce (option no);
  SCHED_TRACER = lib.mkForce (option no);
  STACK_TRACER = lib.mkForce (option no);
  X86_SGX_KVM = lib.mkForce (option no);

  # Fonts
  FONTS = yes;
  FONT_8x16 = yes;
  FONT_TER16x32 = yes;
  FONT_CJK_16x16 = yes;
  FONT_CJK_32x32 = yes;

  # Linux RNG framework
  LRNG = yes;
  LRNG_IRQ = yes;
  LRNG_CONTINUOUS_COMPRESSION_ENABLED = yes;
  LRNG_ENABLE_CONTINUOUS_COMPRESSION = yes;
  LRNG_JENT = yes;
  LRNG_CPU = yes;
  LRNG_DRNG_SWITCH = yes;
  LRNG_KCAPI_HASH = yes;
  LRNG_DRBG = yes;

  # Reduce log buffer size
  LOG_BUF_SHIFT = freeform "12";
  LOG_CPU_MAX_BUF_SHIFT = freeform "12";
  PRINTK_SAFE_LOG_BUF_SHIFT = freeform "10";

  # Ultra KSM
  UKSM = yes;
  KSM_LEGACY = no;

  # Use ZSTD wherever possible
  MODULE_COMPRESS_XZ = lib.mkForce no;
  MODULE_COMPRESS_ZSTD = yes;

  # Various tunings
  FAT_DEFAULT_UTF8 = yes;
  FSCACHE_STATS = yes;
  LRU_GEN = yes;
  LRU_GEN_ENABLED = yes;
  NTFS_FS = no;
  PSTORE_ZSTD_COMPRESS = yes;
  PSTORE_ZSTD_COMPRESS_DEFAULT = yes;

  # ZRAM & Zswap
  ZRAM = lib.mkForce yes;
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

  # AMD P-state driver
  X86_AMD_PSTATE = yes;

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

  # Graysky's additional CPU optimizations
  CC_OPTIMIZE_FOR_PERFORMANCE_O3 = yes;

  # Futex WAIT_MULTIPLE implementation for Wine / Proton Fsync.
  FUTEX = yes;
  FUTEX_PI = yes;

  # WineSync driver for fast kernel-backed Wine
  WINESYNC = module;
}
