{
  stdenv,
  runCommand,
  xwin,
}:
assert stdenv.hostPlatform.isx86_64;
runCommand "msvc-sdk"
  {
    buildInputs = [ xwin ];

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-2MfUJDwScir/V9+aCu94RYPexSEKGemn92ZNclfYNIw=";

    manifest = ./manifest.json;
  }
  ''
    xwin --accept-license --cache-dir=xwin-out --manifest=$manifest splat --preserve-ms-arch-notation --use-winsysroot-style
    mkdir $out/
    mv xwin-out/splat/* $out/

    echo "Fixing directory names..."
    pushd $out/Windows\ Kits/10/
    mv include Include
    mv lib Lib
    popd
    echo "Fixed"
  ''
