{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "portolan";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "fitnr";
    repo = "portolan";
    tag = "v${version}";
    hash = "sha256-zKloFO7uCLkqgayxC11JRfMpNxIR+UkT/Xabb9AH8To=";
  };

  build-system = with python3Packages; [ setuptools ];

  pythonImportsCheck = [ "portolan" ];

  meta = {
    description = "Convert between compass points and degrees";
    homepage = "https://github.com/fitnr/portolan";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
