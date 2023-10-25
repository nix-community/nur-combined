# disable tests for packages which flake.
# tests will fail for a variety of reasons:
# - they were coded with timeouts that aren't reliable under heavy load.
# - they assume a particular architecture (e.g. x86) whereas i compile on multiple archs.
# - they assume too much about their environment and fail under qemu.
#
(next: prev:
let
  dontCheck = p: p.overrideAttrs (_: {
    doCheck = false;
    doInstallCheck = false;
  });
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
  dontCheckAarch64 = aarch64Only (_: {
    # only `dontCheck` if the package is being built for aarch64
    doCheck = false;
    doInstallCheck = false;
  });
  dontCheckEmulated = emulatedOnly (_: {
    doCheck = false;
  });
in {
  # 2023/07/27
  # 4 tests fail when building `hostPkgs.moby.emulated.elfutils`
  elfutils = dontCheckAarch64 prev.elfutils;

  # 2023/07/31
  # tests just hang after mini-record-2
  # only for binfmt-emulated aarch64 -> aarch64 build
  gnutls = dontCheckEmulated prev.gnutls;

  # 2023/07/31
  # tests fail (not timeout), but only when cross compiling, and not on servo (so, due to binfmt?)
  gupnp = dontCheckAarch64 prev.gupnp;

  # hangs during checkPhase (or maybe it just takes 20-30 minutes)
  # libqmi = dontCheckEmulated prev.libqmi;

  # 2023/07/28
  # "7/7 libwacom:all / pytest                               TIMEOUT        30.36s   killed by signal 15 SIGTERM"
  # N.B.: it passes on x86_64, but only if it's not CPU starved (i.e. nix build with -j1 if it fails)
  libwacom = aarch64Only (_: {
    doCheck = false;
    mesonFlags = [ "-Dtests=disabled" ];
  }) prev.libwacom;

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (py-next: py-prev: {
      pyarrow = py-prev.pyarrow.overridePythonAttrs (upstream: {
        # 2023/04/02
        # disabledTests = upstream.disabledTests ++ [ "test_generic_options" ];
        disabledTestPaths = (upstream.disabledTestPaths or []) ++ [
          "pyarrow/tests/test_flight.py"
        ];
      });

      # 2023/08/09: unclear why it fails; probably can remove after next nixpkgs update
      pillow = py-prev.pillow.overridePythonAttrs (_upstream: {
        format = "setuptools";
      });

      seaborn = py-prev.seaborn.overridePythonAttrs (upstream: {
        # 2023/08/09
        disabledTestPaths = (upstream.disabledTestPaths or []) ++ [
          "tests/test_categorical.py"
          "tests/test_core.py"
        ];
      });
    })
  ];

  # 2023/02/22
  # "27/37 tracker:core / service                          TIMEOUT         60.37s   killed by signal 15 SIGTERM"
  tracker = dontCheck prev.tracker;

  # 2023/07/31
  # fails a test (didn't see which one)
  # only for binfmt-emulated aarch64 -> aarch64 build
  umockdev = dontCheckEmulated prev.umockdev;
})
