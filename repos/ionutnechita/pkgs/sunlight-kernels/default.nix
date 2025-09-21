{
  lib,
  stdenv,
  fetchFromGitHub,
  buildLinux,
  variant,
  ...
}@args:

let
  variants = {
    stable = {
      version = "6.16.8";
      suffix = "lowlatency-sunlight1";
      hash = "sha256-GsMnYH3oj1W9Z6TUPKvoohb0w5Q8fCR7uIDl1VYr3rM=";
    };
    mainline = {
      version = "6.17.0-rc6";
      suffix = "lowlatency-sunlight1";
      hash = "sha256-wqkaa0VIuTtb9VNFRYSzBhKdiaRrGlK2VOYMoR5bVD8=";
    };
  };

  sunlightKernelFor =
    {
      version,
      suffix,
      hash,
    }:
    let
      modDirVersion = "${version}-${suffix}";
      numbers = lib.splitString "." version;
      branch = "${lib.elemAt numbers 0}.${lib.elemAt numbers 1}";
      rev = modDirVersion;
    in
    buildLinux (
      args
      // rec {
        inherit version modDirVersion;
        pname = "linux-sunlight";

        src = fetchFromGitHub {
          owner = "sunlightlinux";
          repo = "linux-sunlight";
          inherit rev hash;
        };

        extraMakeFlags = [
          "KBUILD_BUILD_VERSION_TIMESTAMP=SUNLIGHT"
        ];

        structuredExtraConfig = with lib.kernel; {
          # Expert option for built-in default values.
          GKI_HACKS_TO_FIX = yes;

          # AMD P-state driver.
          X86_AMD_PSTATE = lib.mkOverride 60 yes;
          X86_AMD_PSTATE_UT = lib.mkForce no;

          # Google's BBRv3 TCP congestion Control.
          TCP_CONG_BBR = yes;
          DEFAULT_BBR = yes;

          # FQ-PIE Packet Scheduling.
          NET_SCH_DEFAULT = yes;
          DEFAULT_FQ_PIE = yes;

          # Futex WAIT_MULTIPLE implementation for Wine / Proton Fsync.
          FUTEX = yes;
          FUTEX_PI = yes;

          # Preemptive Full Tickless Kernel at 858Hz.
          LATENCYTOP = yes;

          PREEMPT = lib.mkOverride 60 yes;
          PREEMPT_VOLUNTARY = lib.mkForce no;
          PREEMPT_NONE = lib.mkForce no;

          # NTSYNC driver for fast kernel-backed Wine.
          NTSYNC = lib.mkOverride 60 yes;

          # Full Cone NAT driver.
          NFT_FULLCONE = module;

          # OpenRGB driver.
          I2C_NCT6775 = module;

          # 858 Hz is alternative to 1000 Hz.
          # Selected value for a balance between latency, performance and low power consumption.
          HZ = freeform "858";
          HZ_858 = yes;
          HZ_1000 = lib.mkForce no;

          # RCU_BOOST and RCU_EXP_KTHREAD
          RCU_EXPERT = yes;
          RCU_FANOUT = freeform "64";
          RCU_FANOUT_LEAF = freeform "16";
          RCU_BOOST = yes;
          RCU_BOOST_DELAY = freeform "0";
          RCU_EXP_KTHREAD = yes;

          SCHEDSTATS = lib.mkOverride 60 yes;
          HID = yes;
          UHID = yes;

          RUST = lib.mkForce no;
          MOUSE_ELAN_I2C = lib.mkForce no;
          SECURITY_APPARMOR_RESTRICT_USERNS = lib.mkForce no;
        };

        ignoreConfigErrors = true;

        extraMeta = {
          inherit branch;
          maintainers = with lib.maintainers; [ ionutnechita ];
          description = "Sunlight Kernel. Built with custom settings and new features built to provide a stable, responsive and smooth desktop experience";
        };
      }
      // (args.argsOverride or { })
    );
in
sunlightKernelFor variants.${variant}
