{ buildPythonPackage
, fetchPypi
, pkgs
, ply
}:

buildPythonPackage rec {
  pname = "CppHeaderParser";
  version = "2.7.4";

  propagatedBuildInputs = [
    ply
  ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "382b30416d95b0a5e8502b214810dcac2a56432917e2651447d3abe253e3cc42";
  };

  # No tests.
  doCheck = false;

  # Verify import still works.
  #pythonImportsCheck = [ "minidump" ];

  meta = with pkgs.lib; {
    description = "Parse C++ header files and generate a data structure representing the class";
    homepage = "http://senexcanis.com/open-source/cppheaderparser/";
    license = licenses.bsd2;
    maintainers = [  ];
  };
}
