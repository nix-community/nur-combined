{
  sources,

  lib,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.time-12) pname src;
  version = lib.removePrefix "v" sources.time-12.version;

  nativeBuildInputs = [ juceCmakeHook ];

  meta = {
    description = "Envelope based delay modulator";
    homepage = "https://github.com/tiagolr/time12";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "TIME-12";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
