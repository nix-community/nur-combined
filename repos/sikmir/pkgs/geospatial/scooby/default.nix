{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "scooby";
  version = "0.5.12";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "banesullivan";
    repo = "scooby";
    rev = "v${version}";
    hash = "sha256-vCZahb9PxII9xX+MztMT3H6NwChD2eCoR08OytGvd74=";
  };

  doCheck = false;

  meta = with lib; {
    description = "Great Dane turned Python environment detective";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
