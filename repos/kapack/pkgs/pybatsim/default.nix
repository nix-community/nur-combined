{ stdenv, python37Packages, procset }:

python37Packages.buildPythonPackage rec {
    pname = "pybatsim";
    version = "3.1.0";

    src = python37Packages.fetchPypi {
      inherit pname version;
      sha256 = "0dmqqk831zplrky114bf5j0p53l84x282zy7q219hzxv6jq0q2wg";
    };

    buildInputs = with python37Packages; [
      autopep8
      coverage
      ipdb
    ];
    propagatedBuildInputs = with python37Packages; [
      sortedcontainers
      pyzmq
      redis
      click
      pandas
      docopt
      procset
    ];

    doCheck = false;

    meta = with stdenv.lib; {
      description = "Python API and Schedulers for Batsim";
      homepage = "https://gitlab.inria.fr/batsim/pybatsim";
      platforms = platforms.unix;
      license = licenses.lgpl3;
      broken = false;

      longDescription = "PyBatsim is the Python API for Batsim.";
    };
}
