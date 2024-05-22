{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "pyspartn";
  version = "0.4.0-beta";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyspartn";
    rev = "v${version}";
    hash = "sha256-5PpCUWOCD8GyOx/9tA3eSKYxCWT2xopqJaV429VSK8M=";
  };

  build-system = with python3Packages; [ setuptools ];

  propagatedBuildInputs = with python3Packages; [ cryptography ];

  pythonImportsCheck = [ "pyspartn" ];

  meta = with lib; {
    description = "SPARTN protocol parser";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
