# disable tests for packages which flake.
# tests will fail for a variety of reasons:
# - they were coded with timeouts that aren't reliable under heavy load.
# - they assume a particular architecture (e.g. x86) whereas i compile on multiple archs.
# - they assume too much about their environment and fail under qemu.
#
(next: prev:
let
  dontCheckFn = _: {
    doCheck = false;
    doInstallCheck = false;
  };
  dontCheck = p: p.overrideAttrs dontCheckFn;
  aarch64Only = f: p: p.overrideAttrs (upstream:
    next.lib.optionalAttrs
      (p.stdenv.targetPlatform.system == "aarch64-linux")
      (f upstream)
  );
  emulatedOnly = f: p: p.overrideAttrs (upstream:
    next.lib.optionalAttrs
      (p.stdenv.targetPlatform.system == "aarch64-linux" && p.stdenv.buildPlatform.system == "aarch64-linux")
      (f upstream)
  );
  # only `dontCheck` if the package is being built for aarch64
  dontCheckAarch64 = aarch64Only dontCheckFn;
  dontCheckEmulated = emulatedOnly dontCheckFn;
in {
  # 2023/07/27
  # 4 tests fail when building `hostPkgs.moby.emulated.elfutils`
  elfutils = dontCheckEmulated prev.elfutils;

  # 2023/10/30: 71/71 gjs:Scripts / CommandLine            TIMEOUT        30.58s   killed by signal 15 SIGTERM
  gjs = dontCheckEmulated prev.gjs;

  # 2023/07/31
  # tests just hang after mini-record-2
  # only for binfmt-emulated aarch64 -> aarch64 build
  gnutls = dontCheckEmulated prev.gnutls;

  # 2023/07/31
  # tests fail (not timeout), but only when cross compiling, and not on servo (so, due to binfmt?)
  # gupnp = dontCheckAarch64 prev.gupnp;

  # hangs during checkPhase (or maybe it just takes 20-30 minutes)
  # libqmi = dontCheckEmulated prev.libqmi;

  # 2023/07/28
  # "7/7 libwacom:all / pytest                               TIMEOUT        30.36s   killed by signal 15 SIGTERM"
  # N.B.: it passes on x86_64, but only if it's not CPU starved (i.e. nix build with -j1 if it fails)
  # libwacom = aarch64Only (_: {
  #   doCheck = false;
  #   mesonFlags = [ "-Dtests=disabled" ];
  # }) prev.libwacom;

  # 2023/02/22; 2023/10/30
  # "27/38 tracker:core / service                          TIMEOUT         60.37s   killed by signal 15 SIGTERM"
  tracker = dontCheckEmulated prev.tracker;

  # 2023/07/31
  # fails a test (didn't see which one)
  # only for binfmt-emulated aarch64 -> aarch64 build
  umockdev = dontCheckEmulated prev.umockdev;
})
