{ lib
, buildPythonApplication
, pythonOlder
, fetchFromGitHub
  # test inputs
, pytestCheckHook
}:

buildPythonApplication rec {
  pname = "tuna";
  version = "0.5.7";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  # Use GitHub b/c some PyPi doesn't include tests
  src = fetchFromGitHub {
    owner = "nschloe";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-pNPknu0zkHVNh2FPnvZNOUnVT+fsQc7EcYy47ilhTVY=";
  };

  dontUseSetuptoolsCheck = true;
  checkInputs = [ pytestCheckHook ];
  preCheck = "export PATH=$out/bin:$PATH";

  meta = with lib; {
    description = "Python profile viewer";
    homepage = "https://github.com/nschloe/tuna";
    changelog = "https://github.com/nschloe/tuna/releases/tag/v${version}";
    license = licenses.gpl3;   # gpl3Only
    maintainers = with maintainers; [ drewrisinger ];
  };
}
