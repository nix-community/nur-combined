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
  version = "2026.07.03";

  src = fetchFromGitHub {
    owner = "pyinstxtractor";
    repo = "pyinstxtractor-ng";
    tag = version;
    hash = "sha256-qSYsg02lF0lqdmRkZ6sbwYnA73JfxqUDMfHE6TNz8sQ=";
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
