{
  sources,

  lib,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.blocks) pname src;
  version = sources.blocks.date;

  nativeBuildInputs = [ juceCmakeHook ];

  meta = {
    description = "User friendly cross platform modular synth";
    homepage = "https://www.soonth.com/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "blocks";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
