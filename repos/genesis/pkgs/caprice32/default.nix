{ lib
, stdenv
, fetchFromGitHub
, desktop-file-utils
, libpng
, pkg-config
, SDL2
, freetype
, zlib
}:

stdenv.mkDerivation rec {

  pname = "caprice32";
  version = "2021-01-04";

  src = fetchFromGitHub {
    repo = "caprice32";
    rev = "06e694d8d1aa94f143680c9c4daffa836cc9b681";
    owner = "ColinPitrat";
    sha256 = "sha256-bO1HJxNp9+aFukvtaoz9WrB6y21ok3Dxu+CpyoRf+2Q=";
  };

  nativeBuildInputs = [ desktop-file-utils pkg-config ];
  buildInputs = [ libpng SDL2 freetype zlib ];

  makeFlags = [
    "APP_PATH=${placeholder "out"}/share/caprice32"
    "RELEASE=1"
    "DESTDIR=${placeholder "out"}"
    "prefix=/"
  ];

  postInstall = ''
    mkdir -p $out/share/icons/
    mv $out/share/caprice32/resources/freedesktop/caprice32.png $out/share/icons/
    mv $out/share/caprice32/resources/freedesktop/emulators.png $out/share/icons/

    desktop-file-install --dir $out/share/applications \
      $out/share/caprice32/resources/freedesktop/caprice32.desktop

    desktop-file-install --dir $out/share/desktop-directories \
      $out/share/caprice32/resources/freedesktop/Emulators.directory

    install -Dm644 $out/share/caprice32/resources/freedesktop/caprice32.menu -t $out/etc/xdg/menus/applications-merged/
  '';

  meta = with lib; {
    description = "A complete emulation of CPC464, CPC664 and CPC6128";
    homepage = "https://github.com/ColinPitrat/caprice32";
    license = licenses.gpl2;
    maintainers = [ maintainers.genesis ];
    platforms = platforms.linux;
  };
}
