{ lib, python3Packages, fetchFromGitHub, libX11, libXext }:

with python3Packages;

let
  pillow-simd = pillow.overrideAttrs (_: rec {
    pname = "Pillow-SIMD";
    version = "6.0.0";

    src = fetchFromGitHub {
      owner = "uploadcare";
      repo = "pillow-simd";
      rev = version;
      sha256 = "05i862vlxndh1wsrr8hvw7k2inr1xfzaj4ywwb0fw7kfaws8fjnf";
    };
  });
in

buildPythonPackage rec {
  pname = "ueberzug";
  version = "18.1.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1rj864sdn1975v59i8j3cfa9hni1hacq0z2b8m7wib0da9apygby";
  };

  postPatch = ''
      substituteInPlace setup.py --replace "pillow-simd" "pillow"
  '';

  buildInputs = [ libX11 libXext ];

  propagatedBuildInputs = [
    xlib
    pillow-simd
    psutil
    docopt
    attrs
  ];

  meta = with lib; {
    homepage = "https://github.com/seebye/ueberzug";
    description = "alternative for w3mimgdisplay";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };

}
