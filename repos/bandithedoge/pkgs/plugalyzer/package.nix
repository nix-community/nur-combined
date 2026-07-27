{
  sources,

  lib,
  stdenv,

  juceCmakeHook,
  ladspa-header,
}:
stdenv.mkDerivation {
  inherit (sources.plugalyzer) pname;
  version = lib.removePrefix "v" sources.plugalyzer.version;
  src = sources.plugalyzer.src.overrideAttrs (_: {
    # https://github.com/NixOS/nixpkgs/issues/195117
    preFetch = ''
      export GIT_CONFIG_COUNT=1
      export GIT_CONFIG_KEY_0=url.https://github.com/.insteadOf
      export GIT_CONFIG_VALUE_0=git@github.com:
    '';
  });

  nativeBuildInputs = [ juceCmakeHook ];

  buildInputs = [ ladspa-header ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp Plugalyzer_artefacts/Release/Plugalyzer $out/bin

    runHook postInstall
  '';

  meta = {
    description = "Command-line VST3, AU and LADSPA plugin host for easier debugging of audio plugins";
    homepage = "https://github.com/CrushedPixel/Plugalyzer";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "Plugalyzer";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
