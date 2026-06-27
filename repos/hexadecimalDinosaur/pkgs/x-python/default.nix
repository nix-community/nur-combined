{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  xdis,
  click,
  six,
}:
buildPythonPackage rec {
  pname = "x-python";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "rocky";
    repo = "x-python";
    tag = version;
    hash = "sha256-R4c0AjcORUrtboPgSARSXlHx4NUML6eigSK5DjQlE0M=";
  };

  pyproject = true;
  buildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    xdis
    click
    six
  ];

  pythonRelaxDeps = [ "xdis" ];

  pythonImportsCheck = [ "xpython" ];

  meta = {
    description = "A Python implementation of the C Python Interpreter";
    homepage = "https://github.com/rocky/x-python";
    changelog = "https://github.com/rocky/x-python/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
    mainProgram = "xpython";
  };
}
