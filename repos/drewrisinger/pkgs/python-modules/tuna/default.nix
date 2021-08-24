{ lib
, buildPythonApplication
, pythonOlder
, fetchFromGitHub
  # test inputs
, pytestCheckHook
}:

buildPythonApplication rec {
  pname = "tuna";
  version = "0.5.8";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  # Use GitHub b/c some PyPi doesn't include tests
  src = fetchFromGitHub {
    owner = "nschloe";
    repo = pname;
    rev = version;
    sha256 = "072w18qjml7rchbb6l35xalqx36xbda4xjskbg2wyz2p510336nd";
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
