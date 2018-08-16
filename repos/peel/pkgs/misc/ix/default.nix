{ stdenv, fetchurl, coreutils, curl, makeWrapper }:

stdenv.mkDerivation rec {
  version = "1.0.0";
  baseName = "ix";
  name = "${baseName}-${version}";

  src = fetchurl {
    sha256 = "0xc2s4s1aq143zz8lgkq5k25dpf049dw253qxiav5k7d7qvzzy57";
    url = "http://ix.io/client";
  };

  buildInputs = [ makeWrapper curl ];
  phases = [ "installPhase" "fixupPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${baseName}
    chmod a+x $out/bin/${baseName}
  '';

  wrapperPath = with stdenv.lib; makeBinPath [
    coreutils
    curl
  ];

  fixupPhase = ''
    patchShebangs $out/bin
    wrapProgram $out/bin/${baseName} --prefix PATH : "${wrapperPath}"
  '';

  meta = with stdenv.lib; {
    description = "A command line pastebin";
    platforms = platforms.unix;
    license = licenses.mit;
  };
}
