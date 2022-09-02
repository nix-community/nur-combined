{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "curses-menu";
  version = "2021-11-26";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "pmbarrett314";
    repo = "curses-menu";
    rev = "574d2b32db937be9442ce9140c42368668bd7d77";
    hash = "sha256-0oBPhdigQ78RaVl0zLAdGN22cF7jXlH4xHXZzE6AedM=";
  };

  propagatedBuildInputs = with python3Packages; [ deprecated pexpect pyte ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "A simple console menu system using curses";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
