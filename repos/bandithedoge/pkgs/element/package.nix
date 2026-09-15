{
  enablePlugins ? true,

  clangStdenv,
  fetchFromGitHub,
  lib,
  nix-update-script,

  boost,
  cairo,
  juce,
  juceCmakeHook,
  ladspa-sdk,
  libjack2,
  libxcomposite,
  lilv,
  lv2,
  pugl,
  sol2,
  suil,
}:
clangStdenv.mkDerivation {
  pname = "element";
  version = "1.2.0-unstable-2026-09-14";
  src = fetchFromGitHub {
    owner = "kushview";
    repo = "element";
    rev = "25fe264ee5fcd911402feda688f58d7798ea33b3";
    hash = "sha256-ileHWSuWg9sG/RTu2FoCYXFMzMOoXRsldP3ExoXCtJ8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    juceCmakeHook
  ];

  buildInputs = [
    juce
    boost
    cairo
    ladspa-sdk
    libjack2
    libxcomposite
    lilv
    lv2
    pugl
    sol2
    suil
  ];

  cmakeFlags = [
    (lib.cmakeBool "ELEMENT_ENABLE_PLUGINS" enablePlugins)
    "-DFETCHCONTENT_SOURCE_DIR_JUCE=${
      fetchFromGitHub {
        owner = "juce-framework";
        repo = "JUCE";
        rev = "8.0.13";
        hash = "sha256-TKqW2rsFMAO1HJZ9IFQ7myOzNRScqR0gmLSLQA5Sw28=";
      }
    }"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp element_app_artefacts/Release/element $out/bin
  '';

  passthru = {
    _ignoreDupe = true;
    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch"
      ];
    };
  };

  meta = {
    description = "A modular AU/LV2/VST/VST3 audio plugin host";
    homepage = "https://kushview.net/element/";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "element";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
