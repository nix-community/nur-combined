{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, cvxopt
, ecos
, multiprocess
, numpy
, osqp
, scipy
, scs
, six
  # Check inputs
, pytestCheckHook
, nose
}:

buildPythonPackage rec {
  pname = "cvxpy";
  version = "1.1.6";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "cvxgrp";
    repo = "cvxpy";
    rev = "v${version}";
    sha256 = "0lr0z17m1a0hh0dkv3zbvh8wdawb13ampj97ivjf3r2wxpjn4rwl";
  };

  propagatedBuildInputs = [
    cvxopt
    ecos
    multiprocess
    osqp
    scs
    six
  ];

  checkInputs = [ pytestCheckHook nose ];
  dontUseSetuptoolsCheck = true;
  pytestFlagsArray = [
    "./cvxpy"
    "--ignore=./cvxpy/cvxcore/"  # seems out of date, many tests fail
  ];
  # Disable the slowest benchmarking tests, cuts test time in half
  disabledTests = [
    "test_tv_inpainting"
    "test_diffcp_sdp_example"
  ];

  meta = with lib; {
    description = "A domain-specific language for modeling convex optimization problems in Python.";
    homepage = "https://www.cvxpy.org/";
    downloadPage = "https://github.com/cvxgrp/cvxpy/releases";
    changelog = "https://github.com/cvxgrp/cvxpy/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
