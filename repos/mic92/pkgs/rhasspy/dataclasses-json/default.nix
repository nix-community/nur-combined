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
  version = "0.4.2";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-Zaya4vfsFS7gG/QsjAJHNtTNb2+3YVAt7JK9VTkx49k=";
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
