{ lib
, python
, buildPythonPackage
, fetchFromGitHub
, scipy
, matplotlib
, joblib
, pandas
, scikit-learn
, pytestCheckHook
}:

let
  pname = "geomstats";
  version = "2.5.0";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "geomstats";
    repo = pname;
    rev = "${version}";
    hash = "sha256-3FP4pgLMjd1qHcWSkwV8bG+tlxMU3LwKCPfgqOjJfpg=";
  };

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

