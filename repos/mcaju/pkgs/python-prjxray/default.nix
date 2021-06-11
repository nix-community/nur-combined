{ stdenv
, lib
, fetchFromGitHub
, buildPythonPackage
, pytestCheckHook
, fasm
, intervaltree
, kijewski-pyjson5
, numpy
, prjxray-tools
, pyyaml
, simplejson
}:

buildPythonPackage rec {
  pname = "python-prjxray";
  version = prjxray-tools.version;

  src = prjxray-tools.src;

  propagatedBuildInputs = [
    fasm
    intervaltree
    kijewski-pyjson5
    numpy
    pyyaml
    simplejson
  ];

  checkInputs = [
    pytestCheckHook
  ];

  doCheck = false;

  meta = with lib; {
    description = "Documenting the Xilinx 7-series bit-stream format";
    homepage    = "https://github.com/SymbiFlow/prjxray";
    license     = licenses.isc;
  };
}
