{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
}:

buildPythonPackage rec {
  pname = "grapheme";
  version = "0.6.0";

  disabled = pythonOlder "3.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-RMK58hu+d8+wWDX+wjC9Q1lUJ1Jn/qGFgBOxAvhgPMo=";
  };

  meta = with lib; {
    description = "A python package for grapheme aware string handling";
    homepage = "https://github.com/alvinlindstam/grapheme";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
