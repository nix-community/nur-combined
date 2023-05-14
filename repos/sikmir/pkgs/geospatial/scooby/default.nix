{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "scooby";
  version = "0.7.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "banesullivan";
    repo = "scooby";
    rev = "v${version}";
    hash = "sha256-eY8Ysc20Q1OHKb/LU+4gqnSgNfHCytjOnnvB24EfQto=";
  };

  propagatedBuildInputs = with python3Packages; [ setuptools ];

  meta = with lib; {
    description = "Great Dane turned Python environment detective";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
