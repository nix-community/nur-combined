{ lib
, buildPythonPackage
, fetchFromGitHub
, cmake
, future
, qdldl
, numpy
  # check inputs
, pytestCheckHook
, scipy
}:

buildPythonPackage rec {
  pname = "osqp";
  version = "0.6.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "oxfordcontrol";
    repo = "osqp-python";
    rev = "v${version}";
    sha256 = "1ix9wf7sfxzfaqwfqry6clpvfxqsfkxarv5h0h0gm0mw6rr9gbg8";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  dontUseCmakeConfigure = true;

  propagatedBuildInputs = [
    numpy
    qdldl
    future
  ];

  checkInputs = [ pytestCheckHook scipy ];
  pythonImportsCheck = [ "osqp" ];
  dontUseSetuptoolsCheck = true;  # running setup.py fails if false
  preCheck = "pushd $TMP/$sourceRoot";  # needed on nixos-20.03, run tests from raw source
  postCheck = "popd";
  disabledTests = [
    # Disabled b/c mkl support not enabled
    "mkl_"
    # Disabled b/c test failing on GitHub Actions, not locally.
    "test_primal_infeasible_problem"
  ];
  pytestFlagsArray = [
    # These cannot collect b/c of circular dependency on cvxpy: https://github.com/oxfordcontrol/osqp-python/issues/50
    "--ignore=module/tests/basic_test.py"
    "--ignore=module/tests/feasibility_test.py"
    "--ignore=module/tests/polishing_test.py"
    "--ignore=module/tests/unconstrained_test.py"
    "--ignore=module/tests/update_matrices_test.py"
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
    maintainers = with lib.maintainers; [ drewrisinger ];
  };
}
