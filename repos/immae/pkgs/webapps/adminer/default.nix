{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  version = "4.7.1";
  name = "adminer-${version}";
  src = fetchurl {
    url = "https://github.com/vrana/adminer/releases/download/v${version}/${name}.php";
    sha256 = "00gnck9vd44wc6ihf7hh4ma6jvdsw69xgjlkbrdf6irnni6rnvhn";
  };
  phases = "installPhase";
  installPhase = ''
    mkdir -p $out
    cp $src $out/index.php
  '';
}
