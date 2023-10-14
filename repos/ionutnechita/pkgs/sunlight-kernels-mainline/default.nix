{ lib, stdenv, fetchFromGitHub, buildLinux, ... } @ args:

let
  modDirVersion = "6.6.0-rc5";
  parts = lib.splitString "-" modDirVersion;
  version = lib.elemAt parts 0;
  suffix = lib.elemAt parts 1;
  extraVer = "";
  hash = "sha256-3R8dD/UiTTgooy7RK9sQsL2puCrvB83nZ/gBRyJAENg=";

  numbers = lib.splitString "." version;
  branch = "${lib.elemAt numbers 0}.${lib.elemAt numbers 1}";
  rev = if ((lib.elemAt numbers 2) == "0") then "${branch}-${suffix}${extraVer}" else "${modDirVersion}${extraVer}";
in
buildLinux (args // rec {
    inherit version modDirVersion;

    src = fetchFromGitHub {
      owner = "sunlightlinux";
      repo = "linux-sunlight";
      rev = "7f640651ba6b6f55907d15ae76ff741dcd75e746";
      inherit hash;
    };

    structuredExtraConfig = with lib.kernel; {
      # Expert option for built-in default values.
      GKI_HACKS_TO_FIX = yes;

      # AMD P-state driver.
      X86_AMD_PSTATE = lib.mkOverride 60 yes;
      X86_AMD_PSTATE_UT = no;

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

      # Selected value for a balance between latency, performance and low power consumption.
      HZ = freeform "1000";
      HZ_1000 = yes;

      SCHEDSTATS = lib.mkOverride 60 yes;
      HID = yes;
      UHID = yes;
    };

    extraMeta = {
      inherit branch;
      maintainers = with lib.maintainers; [ ];
      description = "Sunlight Kernel. Built with custom settings and new features
                     built to provide a stable, responsive and smooth desktop experience";
      broken = stdenv.isAarch64;
    };
} // (args.argsOverride or { }))
