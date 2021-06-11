{ stdenv
, lib
, fetchPypi
, buildPythonPackage
, cython
}:

buildPythonPackage rec {
  pname = "pyjson5";
  version = "1.5.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0h9qqw3fk6cn5ddb7qqchli30zyq982zbyjr1r3cqcb8xb0wbirf";
  };

  propagatedBuildInputs = [
  ];

  nativeBuildInputs = [
    cython
  ];

  meta = with lib; {
    description = "A JSON5 serializer and parser library for Python 3 written in Cython.";
    homepage    = "https://pyjson5.readthedocs.io/en/latest/";
    license     = licenses.asl20;
  };
}
