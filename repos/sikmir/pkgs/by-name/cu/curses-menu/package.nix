{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "curses-menu";
  version = "0.9.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pmbarrett314";
    repo = "curses-menu";
    tag = finalAttrs.version;
    hash = "sha256-QEIH7kzvjuqkhEynQuB0t6cAIGrwkY00QLISe9KsEgc=";
  };

  build-system = with python3Packages; [ hatchling ];

  dependencies = with python3Packages; [
    deprecated
    pexpect
    pyte
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-cov
  ];

  doCheck = false;

  meta = {
    description = "A simple console menu system using curses";
    homepage = "https://github.com/pmbarrett314/curses-menu";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
