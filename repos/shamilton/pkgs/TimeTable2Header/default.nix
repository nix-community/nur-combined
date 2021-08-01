{ lib
, python3Packages
, fetchFromGitHub 
}:

python3Packages.buildPythonPackage rec {
  pname = "TimeTable2Header";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "TimeTable2Header";
    rev = "ac6bf7bac4bbc653080ddb2819688ad03ed6d939";
    sha256 = "0ccbly6qd2zrjxnr6r8x5gbypg0nmzryii64y3qndyh5d2ivlw2j";
  };

  propagatedBuildInputs = with python3Packages; [
    click
    numpy
    odfpy
    pandas
  ];

  doCheck = false;

  meta = with lib; {
    description = "Keepass Databases Merging script";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
