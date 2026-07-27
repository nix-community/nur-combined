{
  sources,

  stdenv,
  lib,
  projucer,
}:
stdenv.mkDerivation {
  inherit (sources.microbiome) pname src;
  version = lib.removePrefix "v" sources.microbiome.version;

  nativeBuildInputs = [
    projucer
  ];

  jucerFile = "Microbiome.jucer";

  meta = {
    description = "A delay-based audio effects plugin";
    homepage = "https://github.com/dsmaugy/microbiome";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
