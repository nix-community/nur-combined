{ stdenv
, fetchurl
, autoPatchelfHook
, libX11
, libXext
}:

stdenv.mkDerivation rec {
  name = "VNC-Viewer-${version}";
  version = "6.20.113-Linux-x64";

  src = fetchurl {
    url = "https://www.realvnc.com/download/file/viewer.files/${name}-ANY.tar.gz";
    sha256 = "b64c5a660651221863ed5b549753b7274a84c80caaf93d19e7174869169263f5";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
  	libX11
	libXext
  ];

  unpackPhase = ''
    tar xvf $src
  '';


  installPhase = ''
    install -m 755 -D VNC-Viewer-6.20.113-Linux-x64/vncviewer $out/bin/vncviewer
    '';

  meta = with stdenv.lib; {
    homepage = https://www.realvnc.com/;
    description = "Real VNC Viewer";
    platforms = platforms.linux;
    maintainers = with maintainers; [ makefu ];
  };

}
