{
  sources,

  lib,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.gate-12) pname src;
  version = lib.removePrefix "#" sources.gate-12.version;

  nativeBuildInputs = [
    juceCmakeHook
  ];

  meta = {
    description = "GATE-12 is a cross-platform envelope generator for gate/volume control inspired by plugins like GrossBeat and ShaperBox. It is the second version of GATE-1 rebuilt from scratch using the JUCE framework";
    homepage = "https://github.com/tiagolr/gate12";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "GATE-12";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
