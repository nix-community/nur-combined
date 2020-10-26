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
  version = "1.1.7";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "cvxgrp";
    repo = "cvxpy";
    rev = "v${version}";
    sha256 = "0v81c20z32574jy5zvrd37qs9hlw8nkbj87yf16rx6y1wl98i07m";
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
