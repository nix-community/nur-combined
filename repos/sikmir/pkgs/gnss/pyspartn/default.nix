{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "pyspartn";
  version = "0.2.0-alpha";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyspartn";
    rev = "v${version}";
    hash = "sha256-Mz+P+FMLXowr0QTDqJR8pKd9VW8G07TvZ3d5slPOEDo=";
  };

  nativeBuildInputs = with python3Packages; [ setuptools ];

  propagatedBuildInputs = with python3Packages; [
    cryptography
  ];

  pythonImportsCheck = [ "pyspartn" ];

  meta = with lib; {
    description = "SPARTN protocol parser";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
