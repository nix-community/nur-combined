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
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "rocky";
    repo = "x-python";
    tag = version;
    hash = "sha256-HUJkVeAIyXDjoZeORkDX2Uf1pAiJ/vEqPnOcK3vyceQ=";
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
