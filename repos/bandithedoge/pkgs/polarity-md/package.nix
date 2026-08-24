{
  fetchzip,
  lib,
  stdenv,
  writeScript,

  autoPatchelfHook,
  juceCmakeHook,
  webkitgtk_4_1,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "polarity-md";
  version = "0.3.8";
  src = fetchzip {
    url = "https://polarity.productions/polarity-md/downloads/PolarityMD-v${finalAttrs.version}-Linux.zip";
    hash = "sha256-3Lfxaliy7HTwpbWQuKYkFPM8RvSDlbwDhBYUeBAWuN4=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = juceCmakeHook.commonBuildInputs ++ [ webkitgtk_4_1 ];

  buildPhase = ''
    mkdir -p $out/{lib/clap,lib/vst3,bin}
    cp CLAP/Polarity-MD.clap $out/lib/clap
    cp -r VST3/Polarity-MD.vst3 $out/lib/vst3
    cp Standalone/Polarity-MD $out/bin

    patchelf --add-needed libwebkit2gtk-4.1.so \
      $out/lib/clap/Polarity-MD.clap \
      $out/lib/vst3/Polarity-MD.vst3/Contents/x86_64-linux/Polarity-MD.so \
      $out/bin/Polarity-MD
  '';

  passthru.updateScript = writeScript "update-polarity-md" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl pcre2 common-updater-scripts

    version="$(curl -s https://polarity.productions/polarity-md/ | pcre2grep -o1 '[Vv](\d+\.\d+\.\d+)')"
    update-source-version "$UPDATE_NIX_ATTR_PATH" "$version"
  '';

  meta = {
    description = "Four-band dynamics with upward + downward compression, per-band clipping";
    homepage = "https://polarity.productions/polarity-md/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "Polarity-MD";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
