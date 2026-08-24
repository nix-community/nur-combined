{
  fetchzip,
  lib,
  stdenv,
  writeScript,

  autoPatchelfHook,
  csound6,
  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tonez";
  version = "2.0.0";
  src = fetchzip {
    url = "https://www.retornz.com/ld/ToneZ_V2-x64-${finalAttrs.version}_Linux.zip";
    sha256 = "sha256-nyHpmuk9KnVyNyeConEj1JSh8C2q79uyR7oIx88wLJo=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    csound6
    stdenv.cc.cc.lib
  ]
  ++ juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/vst3
    cp -r ToneZ_V2.vst3 $out/lib/vst3

    runHook postBuild
  '';

  passthru.updateScript = writeScript "update-tonez" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl pcre2 common-updater-scripts

    version="$(curl -s "https://www.retornz.com/plugins/tonez" | pcre2grep -o1 'V(\d+\.\d+\.\d+)')"
    update-source-version "$UPDATE_NIX_ATTR_PATH" "$version"
  '';

  meta = {
    description = "Free cross-platform polyphonic synthesizer";
    homepage = "https://www.retornz.com/plugins/tonez";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
