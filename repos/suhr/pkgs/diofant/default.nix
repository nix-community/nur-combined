{ lib, buildPythonPackage, fetchPypi
, glibcLocales, pytestrunner, setuptools_scm
, mpmath, isort
, multipledispatch, toolz
, pytest
}:

let
  strategies = buildPythonPackage rec {
    pname = "strategies";
    version = "0.2.3";

    src = fetchPypi {
      inherit pname version;
      sha256 = "02i4ydrs9k61p8iv2vl2akks8p9gc88rw8031wlwb1zqsyjmb328";
    };

    propagatedBuildInputs = [ multipledispatch toolz ];
    checkInputs = [ pytest ];

    meta = {
      description = "A Python library for control flow programming";
      homepage    = "https://github.com/logpy/strategies";
      license     = lib.licenses.mit;
      maintainers = with lib.maintainers; [ suhr ];
    };
  };
in 
  buildPythonPackage rec {
    pname = "diofant";
    version = "0.10.0";

    src = fetchPypi {
      inherit version;
      pname = "Diofant";
      sha256 = "0qjg0mmz2cqxryr610mppx3virf1gslzrsk24304502588z53v8w";
    };

    checkInputs = [ glibcLocales pytestrunner ];
    nativeBuildInputs = [ pytestrunner setuptools_scm ];
    propagatedBuildInputs = [ mpmath isort strategies ];

    # tests take ~1h
    doCheck = false;

    preCheck = ''
      export LANG="en_US.UTF-8"
    '';

    meta = {
      description = "A Python CAS library";
      homepage    = "https://diofant.readthedocs.io/";
      license     = lib.licenses.bsd3;
      maintainers = with lib.maintainers; [ suhr ];
    };
  }
