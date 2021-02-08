{ lib, stdenv, fetchFromGitHub, buildPythonPackage, pytest, dtlssocket
, cryptography, cbor, hkdf, linkheader, cython }:

buildPythonPackage rec {
  pname = "aiocoap";
  version = "0.4a1";

  src = fetchFromGitHub {
    owner = "chrysn";
    repo = "aiocoap";
    rev = version;
    sha256 = "0fv5w2lr172wsvpkzcybzgff0q4bps3x04r5gh15giayv1jg4wn2";
  };

  nativeBuildInputs = [ cython ];
  propagatedBuildInputs = [ dtlssocket cryptography cbor hkdf linkheader ];
  checkInputs = [ pytest ];

  # TODO: tests fail with python 3.7
  # https://github.com/chrysn/aiocoap/issues/127
  doCheck = false;

  meta = with lib; {
    description = "The Python CoAP library";
    homepage = "https://github.com/chrysn/aiocoap";
    # license is "AS IS"
  };
}
