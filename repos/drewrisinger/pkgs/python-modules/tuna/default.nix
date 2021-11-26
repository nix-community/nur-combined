{ lib
, buildPythonApplication
, pythonOlder
, fetchFromGitHub
  # test inputs
, pytestCheckHook
}:

buildPythonApplication rec {
  pname = "tuna";
  version = "0.5.10";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  # Use GitHub b/c some PyPi doesn't include tests
  src = fetchFromGitHub {
    owner = "nschloe";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-ilwZCIFM1k9o0mrB/DSlMaawtYR75mEjSfj0f2hjkxo=";
  };

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
