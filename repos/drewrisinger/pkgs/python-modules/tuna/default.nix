{ lib
, buildPythonApplication
, pythonOlder
, fetchPypi
  # test inputs
, pytestCheckHook
}:

buildPythonApplication rec {
  pname = "tuna";
  version = "0.4.7";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  # Use PyPi b/c some Javascript files aren't included in GitHub checkout
  src = fetchPypi {
    inherit pname version;
    sha256 = "7a4eb545bde7eb5cd43a7d1233e55c15bfe3101a0fff3da5cde1ff68b2191bcb";
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
