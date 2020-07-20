{ stdenv, fetchFromGitHub
, fpc, lazarus, makeWrapper
, atk, cairo, gdk_pixbuf, glib, gtk2-x11, libX11, pango
}:

stdenv.mkDerivation rec {
  pname = "goverlay";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "benjamimgois";
    repo = pname;
    rev = version;
    sha256 = "1shvgnjzjxd4fvxjbzs2zqvfj0bznja2c0sgahxlp2xjq65bxkgk";
  };

  nativeBuildInputs = [ fpc lazarus makeWrapper ];
  buildInputs = [ atk cairo gdk_pixbuf glib gtk2-x11 libX11 pango ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace 'prefix = /usr/local' "prefix = $out"
  '';

  buildPhase = ''
    lazbuild --lazarusdir=${lazarus}/share/lazarus -B goverlay.lpi
  '';

  postInstall = ''
    wrapProgram "$out/bin/goverlay" \
      --prefix LD_LIBRARY_PATH : "${stdenv.lib.makeLibraryPath buildInputs}"
  '';

  meta = with stdenv.lib; {
    description = "An opensource project that aims to create a Graphical UI to help manage Linux overlays";
    homepage = "https://github.com/benjamimgois/goverlay";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.linux;
  };
}
