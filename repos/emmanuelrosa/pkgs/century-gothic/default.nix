{ stdenv, lib, fetchurl, unzip }:

let
  description = "Century Gothic font.";
in stdenv.mkDerivation rec {
  name = "century-gothic-${version}";
  version = "2016-09-17";

  src = ./century-gothic.zip;

  nativeBuildInputs = [ unzip ];

  unpackCmd = ''
    mkdir century-gothic
    pushd century-gothic
    unzip $curSrc
    popd
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/century-gothic

    cp -r ./*.TTF $out/share/fonts/century-gothic
  '';

  meta = with lib; {
    inherit description;
    homepage = https://www.dafontfree.net;
    license = licenses.unfree;
    platforms = platforms.all;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
