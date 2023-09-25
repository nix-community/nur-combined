{ lib
, python
, buildPythonPackage
, fetchFromGitHub
, scipy
, matplotlib
, joblib
, pandas
, scikit-learn
, setuptools
, pytestCheckHook
}:

let
  pname = "geomstats";
  version = "2.7.0";
in
buildPythonPackage {
  inherit pname version;
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "geomstats";
    repo = pname;
    rev = "${version}";
    hash = "sha256-4+6lwu9zvzSZed/ytKYrscEXI2cmz4A5sMMHV/7gxTc=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    scipy
    matplotlib
    joblib
    pandas
    scikit-learn
  ];

  checkInputs = [
    pytestCheckHook
  ];

  pytestFlagsArray = [
    "--maxfail"
    "1"
    # A single test is enough...
    "tests/tests_geomstats/test_poincare_ball.py"
  ];

  pythonImportsCheck = [
    "geomstats"
  ];

  # disabledTestPaths = [
  #   "tests/tests_geomstats/test_backends.py"
  #   "tests/test_notebooks.py"
  # ];

  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.mit;
    description = "Computations and statistics on manifolds with geometric structures in Python";
    homepage = "https://geomstats.github.io/";
    platforms = lib.platforms.unix;
  };
}

