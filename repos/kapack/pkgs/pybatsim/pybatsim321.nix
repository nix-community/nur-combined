{ lib, python3Packages, poetry, procset }:

python3Packages.buildPythonPackage rec {
  pname = "pybatsim";
  version = "3.2.1";
  format = "pyproject";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "1gxvjnriklllj4qmiyvg8cf9ilwkpsh4p37kihgwgrgzgxr658ab";
    };
  patches = [ ./321-0001-bs-loosen-pyzmq-version-constraint.patch ];

  buildInputs = with python3Packages; [
    poetry
  ];
  propagatedBuildInputs = with python3Packages; [
    docopt
    procset
    pyzmq
    sortedcontainers
  ];

  doCheck = false;

  meta = with lib; {
    description = "Python API and schedulers for Batsim";
    homepage = "https://gitlab.inria.fr/batsim/pybatsim";
    platforms = platforms.all;
    license = licenses.lgpl3;
    broken = false;

    longDescription = "Python API and schedulers for Batsim";
  };
}
