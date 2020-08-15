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
, nose
}:

buildPythonPackage rec {
  pname = "cvxpy";
  version = "1.1.4";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "cvxgrp";
    repo = "cvxpy";
    rev = "v${version}";
    sha256 = "1mhcg3w4zbxq458yv1pc90x5xwmbmwx2h7a2j9nm7r1ylaakjk5r";
  };

  propagatedBuildInputs = [
    cvxopt
    ecos
    multiprocess
    osqp
    scs
    six
  ];

  checkInputs = [ nose ];
  checkPhase = ''
    nosetests cvxpy
  '';

  meta = with lib; {
    description = "A domain-specific language for modeling convex optimization problems in Python.";
    homepage = "https://www.cvxpy.org/";
    downloadPage = "https://github.com/cvxgrp/cvxpy/";
    license = licenses.asl20;
    # maintainers = with maintainers; [ drewrisinger ];
  };
}
