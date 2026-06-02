{
  stdenv,
  runCommand,
  python3Packages,
  jemalloc,
  rust-jemalloc-sys,
}:
let
  polarsJemalloc = rust-jemalloc-sys.override {
    jemalloc = jemalloc.override { disableInitExecTls = true; };
  };
in
(python3Packages.polars.override {
  polarsMemoryAllocator = polarsJemalloc;
}).overrideAttrs
  (
    finalAttrs: prevAttrs: {
      passthru = builtins.removeAttrs prevAttrs.passthru [ "updateScript" ] // {
        tests =
          let
            polars = finalAttrs.finalPackage;
            pythonEnv = python3Packages.python.withPackages (_: [ polars ]);
            expectedAllocSymbol = if stdenv.hostPlatform.isUnix then "jemalloc" else "mimalloc";
            expectedPageSizeKiB =
              if
                stdenv.hostPlatform.isAarch64 || stdenv.hostPlatform.isLoongArch64 || stdenv.hostPlatform.isPower64
              then
                64
              else
                4;
            expectedPageSizeBytes = toString (expectedPageSizeKiB * 1024);
          in
          {
            page-size =
              let
                getconfBin =
                  if stdenv.hostPlatform.isDarwin then "/usr/bin/getconf" else "${stdenv.cc.libc.bin}/bin/getconf";
              in
              runCommand "polars-page-size-${toString expectedPageSizeKiB}k" { inherit expectedPageSizeBytes; } ''
                actual=$(${getconfBin} PAGESIZE)
                if [ "$actual" -gt "$expectedPageSizeBytes" ]; then
                  exit 1
                fi
                touch $out
              '';

            import =
              runCommand "polars-import-${toString expectedPageSizeKiB}k" { nativeBuildInputs = [ pythonEnv ]; }
                ''
                  python -c 'import polars as pl; df = pl.DataFrame({"a": [1, 2, 3]}); assert df.sum().item() == 6; print(df)'
                  touch $out
                '';

            allocator =
              runCommand "polars-allocator-${expectedAllocSymbol}"
                {
                  inherit expectedAllocSymbol;
                  sitePackages = "${polars}/${python3Packages.python.sitePackages}";
                }
                ''
                  runtimeSo=$(find "$sitePackages" -type f \( -name '_polars*.abi3.so' -o -name 'polars.so' \) -print -quit)
                  if [ -z "$runtimeSo" ]; then
                    echo "polars runtime .so not found under $sitePackages" >&2
                    exit 1
                  fi
                  if ! grep -aFq "$expectedAllocSymbol" "$runtimeSo"; then
                    echo "expected allocator '$expectedAllocSymbol' not linked into $runtimeSo" >&2
                    exit 1
                  fi
                  touch $out
                '';
          };
      };
    }
  )
