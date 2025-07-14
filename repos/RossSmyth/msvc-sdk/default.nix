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
    outputHash = "sha256-UxKqx4E6yr1Bjy8uIw+g3+RKijKOQYU5Gf1gUt6qy+E=";

    manifest = ./manifest.json;
  }
  ''
    xwin --accept-license --cache-dir=xwin-out --manifest=$manifest splat --preserve-ms-arch-notation --use-winsysroot-style
    mkdir $out/
    mv xwin-out/splat/* $out/

    pushd $out/Windows\ Kits/10/
    mv include Include
    mv lib Lib
    popd
  ''
