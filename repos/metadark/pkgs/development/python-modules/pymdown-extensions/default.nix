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
  version = "8.1";

  src = fetchFromGitHub {
    owner = "facelessuser";
    repo = pname;
    rev = version;
    sha256 = "1zczq8r1famz951l6m4y6hq0sv4g59jcy0xc2prbil367d02y8r5";
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
