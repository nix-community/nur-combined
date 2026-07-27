{
  sources,

  lib,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.perceptomap) pname src;
  version = lib.removePrefix "v" sources.perceptomap.version;

  nativeBuildInputs = [
    juceCmakeHook
  ];

  cmakeFlags = [ "-DFETCHCONTENT_SOURCE_DIR_JUCE=${sources.juce.src}" ];

  meta = {
    description = "From frequencies to feeling";
    homepage = "https://github.com/hqrrr/PerceptoMap";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
