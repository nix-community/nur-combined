{ stdenv
, lib
, fetchFromGitHub
, buildPythonPackage
, pytestCheckHook
, intervaltree
, numpy
, openpyxl
, parse
, prjxray-tools
, progressbar
, pyjson5
, pyyaml
, simplejson
, fasm
, textx
}:

buildPythonPackage rec {
  pname = "python-prjxray";
  version = prjxray-tools.version;

  src = prjxray-tools.src;

  propagatedBuildInputs = [
    fasm
    intervaltree
    numpy
    openpyxl
    parse
    progressbar
    pyjson5
    pyyaml
    simplejson
    textx
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
