{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  xdis,
  click,
  six,
  x-python
}:
buildPythonPackage rec {
  pname = "xasm";
  version = "1.2.0-unstable-2025-06-21";

  src = fetchFromGitHub {
    owner = "rocky";
    repo = "python-xasm";
    rev = "a613e47ab278651207cb6df00ec7b1989e96e019";
    hash = "sha256-bI2cuOuQKg3VmQmQ6vm3ekO1PjOrCdWDPekuwuDiCBI=";
  };

  pyproject = true;

  buildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    xdis
    click
    six
    x-python
  ];

  pythonImportsCheck = [ "xasm" ];

  meta = {
    description = "Python cross version bytecode/wordcode assembler";
    homepage = "https://github.com/rocky/xasm";
    changelog = "https://github.com/rocky/xasm/releases/tag/${version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
    mainProgram = "pyc-xasm";
  };
}
