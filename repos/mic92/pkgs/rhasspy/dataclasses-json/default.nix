{ lib
, buildPythonPackage
, fetchPypi
, dataclasses
, marshmallow
, marshmallow-enum
, typing-inspect
, stringcase
, pythonOlder
}:

buildPythonPackage rec {
  pname = "dataclasses-json";
  version = "0.4.5";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "8026790fc917437d2949cd0d78af650d7c1b2f5055f13336a3a4aa32bd61a293";
  };

  propagatedBuildInputs = [
    marshmallow
    marshmallow-enum
    typing-inspect
    stringcase
  ] ++ lib.optional (pythonOlder "3.7")
    dataclasses;

  meta = with lib; {
    description = "Easily serialize dataclasses to and from JSON";
    homepage = "https://github.com/lidatong/dataclasses-json";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
