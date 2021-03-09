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
  version = "0.0.2-gaf39a4fb";

  src = fetchFromGitHub {
    owner = "Symbiflow";
    repo = "fasm";
    rev = "af39a4fb7adc367502ed91ac7f0b8f1c17f37ee8";
    sha256 = "0swk4nks1lbx2cp4dz3z127sj0x4s7a3cbz47niy6gf0i73znijr";
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
