{ lib
, python3Packages
, fetchFromGitHub 
}:

python3Packages.buildPythonPackage rec {
  pname = "merge-keepass";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "merge-keepass";
    rev = "ff314141625a558db1e6c91eadc77d0b780f4b61";
    sha256 = "06yaxx5vvrm36kz6474da8n7a60cgpgwzkj7pp4pm6x2hn3pr6d7";
  };

  propagatedBuildInputs = with python3Packages; [ pykeepass click ];
  checkInputs = with python3Packages; [ pytest ];

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
