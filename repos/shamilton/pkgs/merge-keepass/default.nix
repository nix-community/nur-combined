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
    rev = "829834fd4de1feb301db8e8d16a0effe10c5c293";
    sha256 = "0n63k5f4rj26b3z0ybw7w61aqp5hdma4n3ginmnrn2sy8v334rgs";
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
