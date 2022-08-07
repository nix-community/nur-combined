{ lib, stdenv, fetchFromGitHub, qmake, qtbase, qt3d, mupdf, mujs, gumbo
, jbig2dec, openjpeg, wrapQtAppsHook }:

stdenv.mkDerivation rec {
  pname = "sioyek";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "ahrm";
    repo = "sioyek";
    rev = "v${version}";
    sha256 = "sha256-F71JXgYaWAye+nlSrZvGjJ4ucvHTx3tPZHRC5QI4QiU=";
  };

  buildInputs = [ qtbase qt3d mupdf mujs gumbo jbig2dec openjpeg ];

  nativeBuildInputs = [ qmake wrapQtAppsHook ];

  preConfigure = ''
    substituteInPlace pdf_viewer/main.cpp \
      --replace /usr/share/sioyek $out/share \
      --replace /etc/sioyek $out/etc
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share
    mkdir -p $out/etc
    cp sioyek $out/bin/
    cp -r pdf_viewer/shaders $out/share/shaders
    cp tutorial.pdf $out/share/tutorial.pdf
    cp pdf_viewer/prefs.config $out/etc/prefs.config
    cp pdf_viewer/prefs_user.config $out/etc/prefs_user.config
    cp pdf_viewer/keys.config $out/etc/keys.config
    cp pdf_viewer/keys_user.config $out/etc/keys_user.config
  '';

  meta = with lib; {
    description =
      "PDF viewer designed for reading research papers and technical books.";
    homepage = "https://github.com/ahrm/sioyek";
    license = licenses.gpl3;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}

