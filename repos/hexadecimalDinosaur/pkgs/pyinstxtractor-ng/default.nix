{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  poetry-core,
  pythonRelaxDepsHook,
  xdis,
  pycryptodome,
}:

buildPythonPackage rec {
  pname = "pyinstxtractor-ng";
  version = "2025.01.06-unstable";

  src = fetchFromGitHub {
    owner = "pyinstxtractor";
    repo = "pyinstxtractor-ng";
    rev = "b733293b0b940a74d007c682143e595cf5cd0511";
    hash = "sha256-ePfu/Hw9WEWRznQq+WgUk9Z31baGDGKjIRpk9iDsAe0=";
  };

  pyproject = true;
  build-system = [ poetry-core ];
  nativeBuildInputs = [
    pythonRelaxDepsHook
  ];

  pythonRelaxDeps = [
    "pycryptodome"
    "xdis"
  ];
  dependencies = [
    xdis
    pycryptodome
  ];

  pythonImportsCheck = [ "pyinstxtractor_ng" ];

  meta = {
    description = "Tool to extract the contents of a Pyinstaller generated executable file";
    homepage = "https://github.com/pyinstxtractor/pyinstxtractor-ng/";
    changelog = "https://github.com/pyinstxtractor/pyinstxtractor-ng/releases/tag/${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
    mainProgram = "pyinstxtractor-ng";
  };
}
