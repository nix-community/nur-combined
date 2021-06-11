{ stdenv
, lib
, fetchFromGitHub
, buildPythonPackage
, pytestCheckHook
, intervaltree
, prjxray-tools
, python-prjxray
, simplejson
, fasm
, textx
}:

buildPythonPackage rec {
  pname = "xc-fasm";
  version = "0.0.1-gfc546c75";

  src = fetchFromGitHub {
    owner = "SymbiFlow";
    repo = "xc-fasm";
    rev = "fc546c75eb9de814024d71e45d740a6eb197b180";
    sha256 = "0shahvr0sq6dsfdizc2h8a1xmgx5nwljpi05332mfssmvln1kzl3";
  };

  propagatedBuildInputs = [
    fasm
    intervaltree
    python-prjxray
    simplejson
    textx
  ];

  postInstall = ''
    wrapProgram $out/bin/xcfasm --prefix PATH : ${lib.makeBinPath [ prjxray-tools ]}
  '';

  meta = with lib; {
    description = "XC FASM libraries";
    homepage = "https://github.com/SymbiFlow/xc-fasm";
    license = licenses.isc;
  };
}
