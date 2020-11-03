{ lib
, stdenv
, fetchFromGitHub
, fpc
, lazarus
, makeWrapper
, atk
, cairo
, gdk_pixbuf
, glib
, gtk2-x11
, libX11
, pango
}:

stdenv.mkDerivation rec {
  pname = "goverlay";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "benjamimgois";
    repo = pname;
    rev = version;
    sha256 = "0i0z6xsj7m8q7mncx80h0x37pbnbjg607lkbdp5i98q1l35yd5dq";
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
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"
  '';

  meta = with lib; {
    description = "An opensource project that aims to create a Graphical UI to help manage Linux overlays";
    homepage = "https://github.com/benjamimgois/goverlay";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.linux;
  };
}
