{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "curses-menu";
  version = "0.7.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pmbarrett314";
    repo = "curses-menu";
    rev = version;
    hash = "sha256-l5KPBPODfeQdZIW3kjoj4ImhokFKjxyiB7r57Ryqj0g=";
  };

  build-system = with python3Packages; [ poetry-core ];

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
}
