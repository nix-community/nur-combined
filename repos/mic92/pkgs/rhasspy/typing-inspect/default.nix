{ lib
, buildPythonPackage
, fetchPypi
, mypy-extensions
, typing
, typing-extensions
, pythonOlder
}:

buildPythonPackage rec {
  pname = "typing-inspect";
  version = "0.6.0";

  src = fetchPypi {
    inherit version;
    pname = "typing_inspect";
    extension = "tar.gz";
    sha256 = "8f1b1dd25908dbfd81d3bebc218011531e7ab614ba6e5bf7826d887c834afab7";
  };

  propagatedBuildInputs = [
    mypy-extensions
    typing-extensions
  ] ++ lib.optional (pythonOlder "3.5")
    typing;

  meta = with lib; {
    description = "Runtime inspection utilities for typing module";
    homepage = "https://github.com/ilevkivskyi/typing_inspect";
    license = licenses.mit;
    # maintainers = [ maintainers.joerg ];
  };
}
