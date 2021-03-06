{ stdenv, fetchurl, lib }:

stdenv.mkDerivation {
  name = "ix";
  version = "latest";

  src = fetchurl {
    url = "http://ix.io/client";
    sha256 = "0xc2s4s1aq143zz8lgkq5k25dpf049dw253qxiav5k7d7qvzzy57";
  };

  phases = "installPhase";

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/ix
    chmod +x $out/bin/ix
  '';

  meta = with lib; {
    homepage = "https://ix.io";
    description = "command line pastebin";
  };
}
