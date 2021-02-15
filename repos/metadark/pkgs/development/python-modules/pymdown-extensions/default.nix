{ lib
, buildPythonPackage
, fetchFromGitHub
, markdown
, pygments
, pytestCheckHook
, pyyaml
}:

buildPythonPackage rec {
  pname = "pymdown-extensions";
  version = "8.1.1";

  src = fetchFromGitHub {
    owner = "facelessuser";
    repo = pname;
    rev = version;
    hash = "sha256-pBE98UKBEqeRtAGXujdcnISIwZEFCCG1XXKWvskMWuY=";
  };

  propagatedBuildInputs = [ markdown ];

  checkInputs = [
    pygments
    pytestCheckHook
    pyyaml
  ];

  meta = with lib; {
    description = "Extensions for Python Markdown";
    homepage = "https://github.com/facelessuser/pymdown-extensions";
    license = licenses.mit;
    maintainers = with maintainers; [ metadark ];
  };
}
