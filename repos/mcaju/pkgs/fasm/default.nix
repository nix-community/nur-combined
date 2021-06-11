{ stdenv
, lib
, pkgs
, fetchFromGitHub
, buildPythonPackage
, cython
, textx
}:

buildPythonPackage rec {
  pname = "fasm";
  version = "0.0.2-g99f199f9";

  src = fetchFromGitHub {
    owner = "Symbiflow";
    repo = "fasm";
    rev = "99f199f9e32fd30c8adffcc73c13caf95a951c35";
    sha256 = "12msxg24pxqqk4dj2431dj7vky6a3r5pi62sl90s7lw8yzqb7lwl";
  };

  nativeBuildInputs = [
    cython
  ];

  dontConfigure = true;

  propagatedBuildInputs = [
    textx
  ];

  doCheck = false;

  meta = with lib; {
    description = "FPGA Assembly (FASM) Parser and Generation library";
    homepage = "https://github.com/SymbiFlow/fasm";
    license = licenses.isc;
  };
}
