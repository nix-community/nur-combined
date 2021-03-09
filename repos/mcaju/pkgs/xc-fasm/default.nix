{ stdenv
, lib
, fetchFromGitHub
, buildPythonPackage
, pytestCheckHook
, intervaltree
, python-prjxray
, simplejson
, fasm
, textx
}:

buildPythonPackage rec {
  pname = "xc-fasm";
  version = "0.0.1-ge12f3133";

  src = fetchFromGitHub {
    owner = "SymbiFlow";
    repo = "xc-fasm";
    rev = "e12f31334e96fedf3af86d13cf51f70ad2270f5f";
    sha256 = "0cx3wp0l7pijj735jz4v07ijkdacws3c3aiafxnziyspmxaclghs";
  };

  propagatedBuildInputs = [
    fasm
    intervaltree
    python-prjxray
    simplejson
    textx
  ];

  doCheck = false;

  meta = with lib; {
    description = "XC FASM libraries";
    homepage = "https://github.com/SymbiFlow/xc-fasm";
    license = licenses.isc;
  };
}
