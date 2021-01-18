{ lib
, buildPythonPackage
, fetchFromGitHub
, cmake
, future
, qdldl
, numpy
  # check inputs
, pytestCheckHook
, cvxopt
, scipy
}:

buildPythonPackage rec {
  pname = "osqp";
  version = "0.6.2.post0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "oxfordcontrol";
    repo = "osqp-python";
    rev = "v${version}";
    sha256 = "1mq5lln4mp4mfckc1ymac1nm2xbh3f904qc4p488r2zr22gqnamr";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  dontUseCmakeConfigure = true;

  propagatedBuildInputs = [
    future
    numpy
    qdldl
    scipy
  ];

  checkInputs = [ pytestCheckHook cvxopt ];
  pythonImportsCheck = [ "osqp" ];
  dontUseSetuptoolsCheck = true;  # running setup.py fails if false
  preCheck = "pushd $TMP/$sourceRoot";  # needed on nixos-20.03, run tests from raw source
  postCheck = "popd";
  disabledTests = [
    # Disabled b/c mkl support not enabled
    "mkl_"
    # Disabled b/c tests failing on GitHub Actions, not locally.
    "test_primal_infeasible_problem"
    "test_feasibility_problem"
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
