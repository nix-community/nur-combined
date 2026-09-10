{
  lib,
  stdenv,
  python3Packages,
  jemalloc,
  rust-jemalloc-sys,

  runCommand,
}:
let
  # polars' vendored jemalloc bakes in the 4K page size of the machine that
  # built it, so imports abort with "Unsupported system page size" on 16K-page
  # aarch64-linux kernels (Asahi). nixpkgs' jemalloc configures
  # --with-lg-page=16, which is safe for any smaller page size. Fixed upstream
  # in 1.42.1; drop this, the four arguments above, and every needsJemalloc
  # reference once nixpkgs-stable ships that.
  needsJemalloc =
    stdenv.hostPlatform.isLinux
    && stdenv.hostPlatform.isAarch64
    && lib.strings.versionOlder python3Packages.polars.version "1.42.1";

  polarsJemalloc = rust-jemalloc-sys.override {
    jemalloc = jemalloc.override { disableInitExecTls = true; };
  };

  polars =
    if needsJemalloc then
      python3Packages.polars.override { polarsMemoryAllocator = polarsJemalloc; }
    else
      python3Packages.polars;
in
polars.overrideAttrs (
  finalAttrs: prevAttrs: {
    passthru = builtins.removeAttrs prevAttrs.passthru [ "updateScript" ] // {
      # The full polars test suite is too heavy for three-system CI, and the
      # dynloading tests load runtime wheels that keep their own vendored
      # jemalloc, which the override cannot reach.
      tests =
        builtins.removeAttrs prevAttrs.passthru.tests (
          [ "pytest" ]
          ++ lib.lists.optionals needsJemalloc [
            "dynloading-1"
            "dynloading-2"
          ]
        )
        // {
          import =
            let
              pythonEnv = python3Packages.python.withPackages (_: [ finalAttrs.finalPackage ]);
            in
            runCommand "polars-import" { nativeBuildInputs = [ pythonEnv ]; } ''
              python -c 'import polars as pl; df = pl.DataFrame({"a": [1, 2, 3]}); assert df.sum().item() == 6; print(df)'
              touch $out
            '';
        }
        // lib.attrsets.optionalAttrs needsJemalloc {
          jemalloc-linkage =
            runCommand "polars-jemalloc-linkage"
              {
                sitePackages = "${finalAttrs.finalPackage}/${python3Packages.python.sitePackages}";
              }
              ''
                runtimeSo=$(find "$sitePackages" -type f -name '_polars*.abi3.so' -print -quit)
                [ -n "$runtimeSo" ]
                grep -aFq ${polarsJemalloc}/lib "$runtimeSo"
                touch $out
              '';
        };
    };
  }
)
