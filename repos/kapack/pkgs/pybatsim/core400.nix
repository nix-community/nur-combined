{ lib, python3Packages, poetry, procset, callPackage }:

python3Packages.buildPythonPackage rec {
  pname = "pybatsim-core";
  version = "4.0.0-alpha+5414b272";
  format = "pyproject";

  # src set to a subdirectory of the whole pybatsim repository
  pybatsim-src = callPackage ./src400.nix { };
  src = "${pybatsim-src}/${pname}";

  buildInputs = with python3Packages; [
    poetry
  ];
  propagatedBuildInputs = with python3Packages; [
    docopt
    procset
    pyzmq
    sortedcontainers
    importlib-metadata
  ];

  doCheck = false;

  meta = with lib; {
    description = "Core Python Python API and schedulers for Batsim";
    homepage = "https://gitlab.inria.fr/batsim/pybatsim";
    platforms = platforms.all;
    license = licenses.lgpl3;
    broken = false;

    longDescription = "Core Python Python API and schedulers for Batsim";
  };
}
