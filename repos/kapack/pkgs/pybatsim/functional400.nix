{ lib, python3Packages, poetry, pybatsim-core, callPackage }:

python3Packages.buildPythonPackage rec {
  pname = "pybatsim-functional";
  version = "4.0.0-alpha+5414b272";
  format = "pyproject";

  # src set to a subdirectory of the whole pybatsim repository
  pybatsim-src = callPackage ./src400.nix { };
  src = "${pybatsim-src}/${pname}";

  buildInputs = with python3Packages; [
    poetry
  ];
  propagatedBuildInputs = with python3Packages; [
    pybatsim-core
    pandas
  ];

  doCheck = false;

  meta = with lib; {
    description = "Functional scheduler API for pybatsim";
    homepage = "https://gitlab.inria.fr/batsim/pybatsim";
    platforms = platforms.all;
    license = licenses.lgpl3;
    broken = false;

    longDescription = "Functional scheduler API for pybatsim";
  };
}
