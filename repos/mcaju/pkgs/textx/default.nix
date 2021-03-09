{ stdenv
, lib
, buildPythonPackage
, fetchPypi
, pytestCheckHook
, arpeggio
, click
, html5lib
, jinja2
}:

buildPythonPackage rec {
  pname = "textX";
  version = "2.3.0";

  src = fetchPypi {
    inherit pname;
    inherit version;
    sha256 = "1b7v9v3npp6m696bb307ky3wqi7dds6cbkf8jivilhmfsh9gqni6";
  };

  checkInputs = [
    pytestCheckHook
    html5lib
  ];

  pytestFlagsArray = [ "tests/functional" ];

  doCheck = false;

  propagatedBuildInputs = [
    arpeggio
    click
    jinja2
  ];

  meta = with lib; {
    description = "textX is a meta-language for building Domain-Specific Languages (DSLs) in Python";
    homepage = "https://textx.github.io";
    license = licenses.mit;
  };
}
