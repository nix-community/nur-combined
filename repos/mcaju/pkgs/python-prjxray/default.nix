{ stdenv
, lib
, fetchFromGitHub
, buildPythonPackage
, intervaltree
, numpy
, openpyxl
, parse
, prjxray-tools
, progressbar
, pyjson5
, pyyaml
, simplejson
, symbiflow-fasm
, textx
}:

buildPythonPackage rec {
  pname = "python-prjxray";
  version = prjxray-tools.version;

  src = prjxray-tools.src;

  propagatedBuildInputs = [
    intervaltree
    numpy
    openpyxl
    parse
    progressbar
    pyjson5
    pyyaml
    simplejson
    symbiflow-fasm
    textx
  ];

  doCheck = false;

  meta = with lib; {
    description = "Documenting the Xilinx 7-series bit-stream format";
    homepage    = "https://github.com/SymbiFlow/prjxray";
    license     = licenses.isc;
  };
}
