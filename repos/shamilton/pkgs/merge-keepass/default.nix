{ lib
, buildPythonPackage
, fetchFromGitHub 
, pykeepass
, click
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
    rev = "master";
    sha256 = "0ww3h9bmkflrhjfzd41q4xv9vyjbhcf4mwyw2hbmh20ihmk5d3vn";
  };

  buildInputs = pyModuleDeps;
  propagatedBuildInputs = pyModuleDeps;

  doCheck = false;

  meta = with lib; {
    description = "Keepass Databases Merging script";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
