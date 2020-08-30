{ buildPythonPackage
, fetchPypi
, pkgs
}:

buildPythonPackage rec {
  pname = "cffi";
  version = "1.14.1";

  propagatedBuildInputs = [
    pkgs.libffi
    pkgs.python37Packages.pycparser
  ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "0bxxw0qhhav13khg9sbaypqqwxd2mvpvlm1105p18dm1fv9b18mj";
  };

  # No tests.
  doCheck = false;

  # Verify import still works.
  pythonImportsCheck = [ "cffi" ];

  meta = with pkgs.lib; {
    description = "Foreign Function Interface for Python calling C code.";
    homepage = "https://pypi.org/project/cffi/";
    license = licenses.bsd2;
    maintainers = [ ];
  };
}
