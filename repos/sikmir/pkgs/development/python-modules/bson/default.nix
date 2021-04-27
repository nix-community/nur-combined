{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "bson";
  version = "0.5.10";

  src = fetchFromGitHub {
    owner = "py-bson";
    repo = pname;
    rev = "a68073661c637051985f3d0c24b8c7828a4c3ff4";
    hash = "sha256-zYx+4lHhc14FogL1voIhR1npqEWtgNtTbtH2SteaAD4=";
  };

  propagatedBuildInputs = with python3Packages; [ python-dateutil six ];

  meta = with lib; {
    description = "Independent BSON codec for Python that doesn't depend on MongoDB";
    inherit (src.meta) homepage;
    license = with licenses; [ bsd3 asl20 ];
    maintainers = [ maintainers.sikmir ];
  };
}
