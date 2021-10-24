{ lib, buildPythonPackage, fetchFromGitHub, pytest }:
buildPythonPackage rec {
  pname = "flake8-annotations-complexity";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "best-doctor";
    repo = pname;
    rev = "b678cafb3ac7471163fad5b11eb1bdc4880c5c74";
    sha256 = "++X+egiilfQmsVz14TBbE/+c7Lkprt+QTlRQVukX6U8=";
  };

  checkInputs = [ pytest ];
  checkPhase = ''
    ${pytest}/bin/pytest
  '';

  meta = with lib; {
    description = "A flake8 extension that checks for type annotations complexity";
    homepage = https://github.com/best-doctor/flake8-annotations-complexity;
    license = licenses.mit;
  };
}

