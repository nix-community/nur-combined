# SPDX-License-Identifier: GPL-2.0-only
# Adapted from xddxdd/nix-cachyos-kernel, revision
# 893cfece885f2af90edc71fd0d8f95a83d72c7e2 (mkCachyKernel/cachySettings).
# Maintained here for our two non-LTO x86-64-v3 kernels; no upstream Nix import.
# See COPYING and README.md for provenance and hash-compatibility constraints.
{
  source,
  variant,
  pname,
  # Supplied by callPackage from the repository's nixpkgs (flake.lock). Never removed
  # from the buildLinux arguments below.
  pkgs,
  ...
}@args:
let
  inherit (pkgs) lib;
  bore = variant == "linux-cachyos-bore";
  version = source.version;
  src = pkgs.fetchurl { inherit (source) url hash; };
  config = pkgs.fetchurl {
    url = source.configUrl;
    hash = source.configHash;
  };
  patchesSrc = pkgs.fetchgit {
    url = "https://github.com/CachyOS/kernel-patches.git";
    rev = source.patchRev;
    rootDir = "${source.patchVersion}/";
    hash = source.patchHash;
  };
  cachyosPatches = lib.optional bore "${patchesSrc}/sched/0001-bore-cachy.patch";
  patchedSrc = pkgs.applyPatches {
    name = "linux-src-patched";
    inherit src;
    patches = [
      pkgs.kernelPatches.bridge_stp_helper.patch
      pkgs.kernelPatches.request_key_helper.patch
    ]
    ++ cachyosPatches;
    prePatch = "";
    postPatch = ''
      install -Dm644 ${config} arch/x86/configs/cachyos_defconfig
    '';
  };
  baseConfig =
    (with lib.kernel; {
      NR_CPUS = lib.mkForce (option (freeform "8192"));
      LOCALVERSION = freeform "-cachyos";
      OVERLAY_FS = module;
      OVERLAY_FS_REDIRECT_DIR = no;
      OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW = yes;
      OVERLAY_FS_INDEX = no;
      OVERLAY_FS_XINO_AUTO = no;
      OVERLAY_FS_METACOPY = no;
      OVERLAY_FS_DEBUG = no;
      HID = yes;
    })
    // lib.mapAttrs (_: lib.mkForce) (
      with lib.kernel;
      {
        CACHY = yes;
        MQ_IOSCHED_ADIOS = yes;
        LTO_NONE = yes;
        LTO_CLANG_THIN = no;
        LTO_CLANG_FULL = no;
        HZ_300 = no;
        HZ_1000 = yes;
        HZ = freeform "1000";
        HZ_PERIODIC = no;
        NO_HZ_IDLE = no;
        CONTEXT_TRACKING_FORCE = no;
        NO_HZ_FULL_NODEF = yes;
        NO_HZ_FULL = yes;
        NO_HZ = yes;
        NO_HZ_COMMON = yes;
        CONTEXT_TRACKING = yes;
        PREEMPT_DYNAMIC = yes;
        PREEMPT = yes;
        PREEMPT_VOLUNTARY = no;
        PREEMPT_LAZY = no;
        PREEMPT_NONE = no;
        CC_OPTIMIZE_FOR_PERFORMANCE = no;
        CC_OPTIMIZE_FOR_PERFORMANCE_O3 = yes;
        TRANSPARENT_HUGEPAGE_MADVISE = no;
        TRANSPARENT_HUGEPAGE_ALWAYS = yes;
        GENERIC_CPU = yes;
        MZEN4 = no;
        X86_NATIVE_CPU = no;
        X86_64_VERSION = freeform "3";
      }
      // lib.optionalAttrs bore { SCHED_BORE = lib.kernel.yes; }
    );
in
assert builtins.elem variant [
  "linux-cachyos"
  "linux-cachyos-bore"
];
assert !(args ? lto) || args.lto == "none";
assert !(args ? processorOpt) || args.processorOpt == "x86_64-v3";
assert !(args ? cpusched) || args.cpusched == (if bore then "bore" else "eevdf");
# NixOS boot.kernelPackages supplies features/kernelPatches/randstructSeed.
# Preserve them and other buildLinux arguments, while fixing our two supported
# CPU/scheduler/compiler variants. Extra configuration deliberately changes hashes.
pkgs.buildLinux (
  (builtins.removeAttrs args [
    "source"
    "variant"
    "pkgs"
  ])
  // {
    inherit pname version;
    src = patchedSrc;
    stdenv = args.stdenv or pkgs.stdenv;
    zfsVariant = variant;
    processorOpt = "x86_64-v3";
    extraMakeFlags = args.extraMakeFlags or [ ];
    defconfig = args.defconfig or "cachyos_defconfig";
    modDirVersion = args.modDirVersion or "${lib.versions.pad 3 version}-cachyos";
    ignoreConfigErrors = args.ignoreConfigErrors or true;
    autoModules = args.autoModules or true;
    structuredExtraConfig = baseConfig // (args.structuredExtraConfig or { });
    extraMeta = {
      description = "Linux CachyOS Kernel";
      broken = !pkgs.stdenv.hostPlatform.isx86_64;
    }
    // (args.extraMeta or { });
    extraPassthru = {
      cachyosConfigFile = config;
      inherit cachyosPatches;
      zfsVariant = variant;
    }
    // (args.extraPassthru or { });
  }
  // lib.optionalAttrs bore { cpusched = "bore"; }
)
