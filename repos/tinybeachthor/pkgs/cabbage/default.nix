{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  libX11,
  libXext,
  alsaLib,
  freetype,
  curl,
  csound,
  gtkd,
  webkitgtk
}:

stdenv.mkDerivation rec {
  pname = "cabbage";
  version = "2.4.0";

  src = fetchzip {
    url = "https://github.com/rorywalsh/cabbage/releases/download/v${version}/CabbageLinux.zip";
    sha256 = "07wc3sgrvji2pnybs5pw3x2f52cbm4n0zg69xkyn3rkygkcr0ig4";
    name = "${pname}-${version}-source-archive";
    stripRoot = true;
    extraPostFetch = ''
      chmod go-w $out
    '';
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    libX11
    libXext
    alsaLib
    freetype
    stdenv.cc.cc.lib
    (curl.override { gnutlsSupport = true; sslSupport = false; })
    csound
    gtkd
    webkitgtk
  ];

  buildPhase = ''
  '';
  installPhase = ''
    rm readme.md
    rm installCabbage

    mkdir -p $out/bin
    cp -r install/bin/* $out/bin

    rm -r install
  '';

  meta = with lib; {
    description = "Cabbage Audio";
    homepage = "https://cabbageaudio.com/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
