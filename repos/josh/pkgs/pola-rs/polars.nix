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
      tests = {
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
