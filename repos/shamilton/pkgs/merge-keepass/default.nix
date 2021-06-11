{ lib
, buildPythonPackage
, fetchFromGitHub 
, pykeepass
, click
, pytest
}:

buildPythonPackage rec {
  pname = "merge-keepass";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "merge-keepass";
    rev = "c9e2df22d0464b6d90ef3f47e1ba24d9a1b64495";
    sha256 = "0nhjy0n9siw9s0cfnkvfzz11d4a7rd17vjpy5j62zn4jw3shqs89";
  };

  propagatedBuildInputs = [ pykeepass click ];
  checkInputs = [ pytest ];

  checkPhase = ''
    pytest tests.py
  '';

  doCheck = true;

  meta = with lib; {
    description = "Keepass Databases Merging script";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
