{
  sources,

  lib,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.hamburger) pname src;
  version = lib.removePrefix "v" sources.hamburger.version;

  nativeBuildInputs = [ juceCmakeHook ];

  cmakeFlags = [
    "-DFETCHCONTENT_SOURCE_DIR_JUCE=${sources.juce.src}"
    "-DFETCHCONTENT_SOURCE_DIR_CLAP-JUCE-EXTENSIONS=${sources.clap-juce-extensions.src}"
    "-DFETCHCONTENT_SOURCE_DIR_CHOWDSP_UTILS=${sources.chowdsp-utils.src}"
    "-DFETCHCONTENT_SOURCE_DIR_XSIMD=${sources.xsimd.src}"
  ];

  meta = {
    description = "Distortion plugin with inbuilt dynamics controls and equalisation that can deliver both subtle tangy harmonics and absolute annilhilation and noise-wall-ification to any sound";
    homepage = "https://aviaryaudio.com/plugins/hamburgerv2";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "Hamburger";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
