{ lib, stdenv, fetchFromGitHub, desktop-file-utils, libpng
, pkgconfig, SDL, freetype, zlib }:

stdenv.mkDerivation rec {

  pname = "caprice32";
  version = "latest";

  src = fetchFromGitHub {
    repo = "caprice32";
    #rev = "v${version}";
    rev = "584d4ab6f4ce178b0a83a6a2d95119213c86fda6";
    owner = "ColinPitrat";
    sha256 = "sha256-5Lpudnws3DcsRXCSAjJNxOwMDwHD6X58ruGiFZqdb5M=";
  };

  nativeBuildInputs = [ desktop-file-utils pkgconfig ];
  buildInputs = [ libpng SDL freetype zlib ];

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
