{ lib
, stdenv
, pythonOlder
, buildPythonPackage
, fetchPypi
, cvxopt
, ecos
, numpy
, osqp
, scipy
, scs
, useOpenmp ? true
  # Check inputs
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "cvxpy";
  version = "1.2.1";
  format = "pyproject";

  disabled = pythonOlder "3.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-bWdkJkPR3bLyr1m0Zrh9QsSi42eDGte0PDO1nu+ltQ4=";
  };

  propagatedBuildInputs = [
    cvxopt
    ecos
    numpy
    osqp
    scipy
    scs
  ];

  preBuild = lib.optional useOpenmp ''
    export CFLAGS="-fopenmp"
    export LDFLAGS="-lgomp"
  '';

  checkInputs = [ pytestCheckHook ];
  pytestFlagsArray = [ "./cvxpy" ];
  # Disable the slowest benchmarking tests, cuts test time in half
  disabledTests = [
    "test_tv_inpainting"
    "test_diffcp_sdp_example"
    # Tests work locally, but fail consistently on GitHub Actions
    "test_cvxopt_sdp"
    "test_psd_nsd_parameters"
    "test_all_solvers"
    "test_constant_atoms"
  ] ++ lib.optionals stdenv.isAarch64 [
    "test_ecos_bb_mi_lp_2" # https://github.com/cvxgrp/cvxpy/issues/1241#issuecomment-780912155
  ];

  meta = with lib; {
    description = "A domain-specific language for modeling convex optimization problems in Python";
    homepage = "https://www.cvxpy.org/";
    downloadPage = "https://github.com/cvxgrp/cvxpy/releases";
    changelog = "https://github.com/cvxgrp/cvxpy/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
