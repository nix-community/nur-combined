{ lib
, buildPythonApplication
, pythonOlder
, fetchFromGitHub
  # test inputs
, pytestCheckHook
}:

buildPythonApplication rec {
  pname = "tuna";
  version = "0.5.6";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  # Use GitHub b/c some PyPi doesn't include tests
  src = fetchFromGitHub {
    owner = "nschloe";
    repo = pname;
    rev = "v${version}";
    sha256 = "0f4s46ik66yfkp4ivlz22s93zjqpmp5y7ddc6yfhnipfwm07pm3l";
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
