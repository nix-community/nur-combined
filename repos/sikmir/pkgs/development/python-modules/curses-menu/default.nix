{ lib, python3Packages, fetchFromGitHub }:

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

  nativeBuildInputs = with python3Packages; [ poetry-core ];

  propagatedBuildInputs = with python3Packages; [ deprecated pexpect pyte ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook pytest-cov ];

  doCheck = false;

  meta = with lib; {
    description = "A simple console menu system using curses";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
