{ lib
, buildPythonPackage
, fetchFromGitHub
, markdown
, pygments
, pytestCheckHook
, pyyaml
, isPy3k
}:

buildPythonPackage rec {
  pname = "pymdown-extensions";
  version = "9.0";

  src = fetchFromGitHub {
    owner = "facelessuser";
    repo = pname;
    rev = version;
    sha256 = "sha256-/FWaBfnoTzCQEkj5ZYoOjWyLRbC3LhowCrjWNju6LyU=";
  };

  propagatedBuildInputs = [ markdown ];

  checkInputs = [
    pygments
    pytestCheckHook
    pyyaml
  ];

  pythonImportsCheck = [ "pymdownx" ];

  meta = with lib; {
    description = "Extensions for Python Markdown";
    homepage = "https://github.com/facelessuser/pymdown-extensions";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
    broken = !isPy3k;
  };
}
