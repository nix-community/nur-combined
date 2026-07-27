{
  sources,

  lib,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.filt-r) pname src;
  version = lib.removePrefix "v" sources.filt-r.version;

  nativeBuildInputs = [ juceCmakeHook ];

  meta = {
    description = "Envelope based filter modulator";
    homepage = "https://github.com/tiagolr/filtr";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "FILT-R";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
