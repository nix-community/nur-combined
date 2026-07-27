{
  sources,

  lib,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.reev-r) pname src;
  version = lib.removePrefix "v" sources.reev-r.version;

  nativeBuildInputs = [ juceCmakeHook ];

  meta = {
    description = "Convolution reverb with pre and post modulation";
    homepage = "https://github.com/tiagolr/reevr";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "REEV-R";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
