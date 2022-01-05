{ lib
, buildPythonPackage
, fetchFromGitHub
, cmake
, future
, qdldl
, numpy
, setuptools_scm ? null
, setuptools-scm ? null
, setuptools-scm-git-archive
  # check inputs
, pytestCheckHook
, cvxopt
, scipy
}:

buildPythonPackage rec {
  pname = "osqp";
  version = "0.6.2.post4";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "oxfordcontrol";
    repo = "osqp-python";
    rev = "v${version}";
    sha256 = "sha256-anYHR2i6xZo/BZb0o2r+4UitgcjgjRsVd9bXoYUwF6Q=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake setuptools_scm setuptools-scm setuptools-scm-git-archive ];
  dontUseCmakeConfigure = true;
  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  propagatedBuildInputs = [
    future
    numpy
    qdldl
    scipy
  ];

  checkInputs = [ pytestCheckHook cvxopt ];
  pythonImportsCheck = [ "osqp" ];
  disabledTests = [
    # Disabled b/c mkl support not enabled
    "mkl_"
    # Disabled b/c tests failing on GitHub Actions, not locally.
    "test_primal_infeasible_problem"
    "test_feasibility_problem"
    "test_multithread"  # can fail sometimes on CI due to build PC (maybe single-threaded/loaded?)
  ];

  meta = with lib; {
    description = "The Operator Splitting QP Solver";
    longDescription = ''
      Numerical optimization package for solving problems in the form
        minimize        0.5 x' P x + q' x
        subject to      l <= A x <= u

      where x in R^n is the optimization variable
    '';
    homepage = "https://osqp.org/";
    downloadPage = "https://github.com/oxfordcontrol/osqp-python/";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
