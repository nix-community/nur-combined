{
  lib,
  stdenv,
  python3Packages,
  jemalloc,
  rust-jemalloc-sys,
  runCommand,
}:
let
  # cache.nixos.org builds polars' vendored jemalloc on 4K-page machines,
  # baking that page size in; the import then aborts with "Unsupported system
  # page size" on 16K-page aarch64-linux kernels (Asahi). nixpkgs' jemalloc
  # configures --with-lg-page=16 (64K) on aarch64, which is safe for any
  # smaller page size, and rust-jemalloc-sys' JEMALLOC_OVERRIDE setup hook
  # makes the vendored build link it instead. Mirrors upstream's unused
  # polarsJemalloc argument.
  needsPageSizeSafeJemalloc = stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64;
  polarsJemalloc = rust-jemalloc-sys.override {
    jemalloc = jemalloc.override { disableInitExecTls = true; };
  };
  polars' =
    if needsPageSizeSafeJemalloc then
      python3Packages.polars.override { polarsMemoryAllocator = polarsJemalloc; }
    else
      python3Packages.polars;
in
polars'.overrideAttrs (
  finalAttrs: prevAttrs: {
    passthru = builtins.removeAttrs prevAttrs.passthru [ "updateScript" ] // {
      # Keep upstream's tests except pytest (the full polars test suite is too
      # heavy for three-system CI). The dynloading tests load extra polars
      # runtime wheels (e.g. _polars_runtime_32) that are separate nixpkgs
      # derivations still carrying the vendored 4K-page jemalloc, which this
      # override cannot reach; they abort on 16K-page kernels, so drop them
      # where the override is active.
      tests =
        builtins.removeAttrs prevAttrs.passthru.tests (
          [ "pytest" ]
          ++ lib.lists.optionals needsPageSizeSafeJemalloc [
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
        // lib.attrsets.optionalAttrs needsPageSizeSafeJemalloc {
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
