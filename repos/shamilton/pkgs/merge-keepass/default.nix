{ lib
, buildPythonPackage
, fetchFromGitHub 
, pykeepass
, click
, pytest
}:
let 
  pyModuleDeps = [
    pykeepass
    click
  ];
in
buildPythonPackage rec {
  pname = "merge-keepass";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "merge-keepass";
    rev = "32dbbe7c6db5d3c0c5a43b7d7b8b97abda45c6a7";
    sha256 = "0van65l37374v9r14rhl9aqw4lfp27kkns8a6b32al4hijw80lvb";
  };

  buildInputs = pyModuleDeps;
  propagatedBuildInputs = pyModuleDeps;

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
