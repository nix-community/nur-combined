{
  common-updater-scripts,
  curl,
  fetchzip,
  lib,
  pcre2,
  stdenv,
  writeScript,

  autoPatchelfHook,
  libxcb,
  libxcb-keysyms,
  systemd,
  unzip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "charlatan";
  version = "3.3.2";
  src = fetchzip {
    url = "https://blaukraut.info/downloads/charlatan3_${finalAttrs.version}_linux.zip";
    sha256 = "sha256-ufbI+infhRPGqju6EPGsjKjzjvSfakFkVPUSKBDwc3I=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
    libxcb
    libxcb-keysyms
    systemd
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/{libexec,lib/vst3,lib/clap}
    cp Charlatan3.so $out/libexec
    cp -r presets $out/libexec

    ln -s $out/libexec/Charlatan3.so $out/lib/clap/Charlatan3.clap
    mkdir -p $out/lib/vst3/Charlatan3.vst3/Contents/x86_64-linux
    ln -s $out/libexec/Charlatan3.so $out/lib/vst3/Charlatan3.vst3/Contents/x86_64-linux/Charlatan3.so

    runHook postBuild
  '';

  passthru.updateScript = writeScript "update-charlatan" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl pcre2 common-updater-scripts

    version="$(curl -s "https://blaukraut.info/" | pcre2grep -o1 '(?:Latest Version) (\d+\.\d+\.\d+)')"
    update-source-version "$UPDATE_NIX_ATTR_PATH" "$version"
  '';

  meta = {
    description = "Charlatan is a virtual analog (VA) synthesizer with focus on sound quality and easy usability";
    homepage = "https://blaukraut.info/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
