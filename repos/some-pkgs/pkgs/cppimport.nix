{ lib
, buildPythonPackage
, fetchFromGitHub
, Mako
, pybind11
, filelock
, pytestCheckHook
, cppimport
, setuptools
}:

let
  pname = "cppimport";
  version = "22.08.02";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "tbenthompson";
    repo = pname;
    rev = "${version}";
    hash = "sha256-L41Vu7t9xAjgK7HaOX3I4FczbQdGVlQl507q1gUjK6s=";
  };

  propagatedBuildInputs = [
    Mako
    pybind11
    filelock
  ];

  doCheck = false;
  checkInputs = [
    setuptools
    pytestCheckHook
  ];

  # Fails: E   AttributeError: module 'distutils' has no attribute 'ccompiler'
  passthru.tests.pytest = cppimport.overridePythonAttrs (_: {
    doCheck = true;
  });


  pythonImportsCheck = [
    "cppimport"
  ];

  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.mit;
    description = "Import C++ files directly from Python!";
    homepage = "https://github.com/tbenthompson/cppimport";
    platforms = lib.platforms.unix;
  };
}
