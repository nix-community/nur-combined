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
  version = "0.7.1";

  src = fetchPypi {
    inherit version;
    pname = "typing_inspect";
    extension = "tar.gz";
    sha256 = "sha256-BH1Al9mxf0ZTG/bwFDVhEaG2+4IaJP56yQmFPKKngqo=";
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
