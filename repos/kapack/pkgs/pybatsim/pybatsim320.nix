{ lib, python3Packages, procset }:

python3Packages.buildPythonPackage rec {
    pname = "pybatsim";
    version = "3.2.0";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "1bv9di8llisk0va16mpvlcszsglxv4cx44pdw1rljj943bnayjyj";
    };

    buildInputs = with python3Packages; [
      autopep8
      coverage
      ipdb
    ];
    propagatedBuildInputs = with python3Packages; [
      sortedcontainers
      pyzmq
      redis
      click
      pandas
      docopt
      procset
    ];

    doCheck = false;

    meta = with lib; {
      description = "Python API and Schedulers for Batsim";
      homepage = "https://gitlab.inria.fr/batsim/pybatsim";
      platforms = platforms.all;
      license = licenses.lgpl3;
      broken = false;

      longDescription = "PyBatsim is the Python API for Batsim.";
    };
}
