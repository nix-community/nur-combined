{
  sources,

  lib,
  stdenv,

  projucer,
}:
stdenv.mkDerivation {
  inherit (sources.plasma) pname src;
  version = lib.removePrefix "v" sources.plasma.version;

  nativeBuildInputs = [
    projucer
  ];

  jucerFile = "Plasma.jucer";

  meta = {
    description = "Asymmetrical Distortion Audio Plugin";
    homepage = "https://github.com/Dimethoxy/Plasma";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
