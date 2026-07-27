{
  sources,

  lib,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.terrain) pname version src;

  nativeBuildInputs = [ juceCmakeHook ];

  NIX_CFLAGS_COMPILE = [ "-Wno-error" ];

  meta = {
    description = "Open Source Wave Terrain Synth";
    homepage = "https://github.com/aaronaanderson/Terrain";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "Terrain";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
