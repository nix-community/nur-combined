{
  sources,

  lib,
  stdenv,

  mpv,
  qt6,
  taglib,
  taglib_1,
}:
stdenv.mkDerivation {
  inherit (sources.musique) pname version src;

  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
    qt6.qttools
  ];

  buildInputs = [
    mpv
    taglib_1
  ];

  postPatch = ''
    substituteInPlace musique.pro --replace-fail /usr/include/taglib ${taglib}/include/taglib
  '';

  meta = {
    description = "A finely crafted music player";
    homepage = "https://flavio.tordini.org/musique";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl3Plus;
    broken = true; # taglib version mismatch or something
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
