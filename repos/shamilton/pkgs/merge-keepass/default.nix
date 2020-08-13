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
    rev = "8e16cf2c685dc61f0c7ce5443866989b9c7fa946";
    sha256 = "138gx3k68i1fanfgal9r2i3lhfw3v8gb9l2ir3pfxr1pyrn067g9";
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
