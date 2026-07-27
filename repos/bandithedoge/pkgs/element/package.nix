{
  sources,

  lib,
  clangStdenv,

  boost,
  cairo,
  juceCmakeHook,
  ladspa-sdk,
  libjack2,
  libxcomposite,
  lilv,
  lv2,
  pugl,
  sol2,
  suil,

  enablePlugins ? true,
}:
clangStdenv.mkDerivation {
  inherit (sources.element) pname src;
  version = sources.element.date;

  nativeBuildInputs = [
    juceCmakeHook
  ];

  buildInputs = [
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
    "-DFETCHCONTENT_SOURCE_DIR_JUCE=${sources.juce.src}"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp element_app_artefacts/Release/element $out/bin
  '';

  passthru._ignoreDupe = true;

  meta = {
    description = "A modular AU/LV2/VST/VST3 audio plugin host";
    homepage = "https://kushview.net/element/";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "element";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
