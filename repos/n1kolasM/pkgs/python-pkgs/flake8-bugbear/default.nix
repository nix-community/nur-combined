{ lib, buildPythonPackage, fetchPypi
, flake8, attrs, importlib-metadata, pythonOlder }:
buildPythonPackage rec {
  pname = "flake8-bugbear";
  version = "19.8.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0w857swdsvrz7lqly9j2g98hjvh297rirwgr1fr0q0nmg7m6di6q";
  };

  # https://github.com/PyCQA/flake8-bugbear/issues/89
  # Minor formatting bug causes testsuite to fail, will be fixed in 19.8.1
  doCheck = false;
  propagatedBuildInputs = [
    flake8
    attrs
  ] ++ lib.optionals (pythonOlder "3.8") [
    importlib-metadata
  ];
  
  meta = with lib; {
    description = "A plugin for flake8 finding likely bugs and design problems in your program.";
    homepage = https://pypi.org/project/flake8-bugbear;
    license = licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}

