{ lib
, buildPythonPackage
, fetchFromGitHub
, fetchpatch
, markdown
, pygments
, pytestCheckHook
, pyyaml
, isPy3k
}:

buildPythonPackage rec {
  pname = "pymdown-extensions";
  version = "9.1";

  src = fetchFromGitHub {
    owner = "facelessuser";
    repo = pname;
    rev = version;
    sha256 = "sha256-II8Po8144h3wPFrzMbOB/qiCm2HseYrcZkyIZFGT+ek=";
  };

  patches = [
    # Fix test failures related to latest Python Markdown
    (fetchpatch {
      url = "https://github.com/facelessuser/pymdown-extensions/commit/8ee5b5caec8f9373e025f50064585fb9d9b71f86.patch";
      sha256 = "sha256-jTHNcsV0zL0EkSTSj8zCGXXtpUaLnNPldmL+krZj3Gk=";
    })
  ];

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
