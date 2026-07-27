{
  sources,

  lib,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.gnomedistort2) pname version src;

  nativeBuildInputs = [
    juceCmakeHook
  ];

  meta = {
    description = "Weird & brutal distortion VST plugin";
    homepage = "https://github.com/crowbait/GnomeDistort-2";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
