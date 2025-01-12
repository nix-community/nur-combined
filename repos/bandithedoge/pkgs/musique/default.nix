{
  pkgs,
  sources,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.musique) pname version src;

  nativeBuildInputs = with pkgs; [
    qt6.qmake
    qt6.wrapQtAppsHook
    qt6.qttools
  ];

  buildInputs = with pkgs; [
    mpv
    taglib
  ];

  postPatch = ''
    substituteInPlace musique.pro --replace-fail /usr/include/taglib ${pkgs.taglib}/include/taglib
  '';

  meta = with pkgs.lib; {
    description = "A finely crafted music player";
    homepage = "https://flavio.tordini.org/musique";
    platforms = platforms.linux;
    license = licenses.gpl3;
  };
}
