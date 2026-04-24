{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "qtpbfimageplugin-styles";
  version = "2026-04-13";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "tumic0";
    repo = "qtpbfimageplugin-styles";
    rev = "da4cec19f72df731ee24f8bd8a32dfdb35f950ab";
    hash = "sha256-1wW4ynK0nvoFsouGBhPgA+JTDKUfAR0Az4ZgW6zlRic=";
  };

  installPhase = ''
    install -dm755 $out
    cp -r * $out
  '';

  meta = {
    description = "QtPBFImagePlugin styles";
    homepage = "https://github.com/tumic0/qtpbfimageplugin-styles";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
  };
}
