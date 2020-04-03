{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
# Python dependencies
, cython
, deap
, ipython
, notebook
, numpy
, plotly
, ply
, scipy
, setuptools_scm
# Other/Optional Python dependencies
, cvxopt
, jinja2
, matplotlib
, mpi4py
, msgpack
, pandas
, psutil
, pyzmq
# Check Inputs
, coverage
, cvxpy
, nose
, rednose
, nose-timer
}:

let
  optionalPackages = [
    deap
    ipython
    jinja2
    mpi4py
    matplotlib
    msgpack
    notebook
    pandas
  ];
in
buildPythonPackage rec {
  pname = "pygsti";
  version = "0.9.9.1";

  src = fetchFromGitHub {
    owner = "pyGSTio";
    repo = pname;
    rev = "v${version}";
    sha256 = "1c028xfn3bcjfvy2wcnm1p6k986271ygn755zxw4w72y1br808zd";
  };

  disabled = pythonOlder "3.5";

  buildInputs = [
    cython
    setuptools_scm  # unused, but easier than patch
  ];

  propagatedBuildInputs = [
    numpy
    plotly
    ply
    scipy
  ] ++ optionalPackages;

  postPatch = ''
    substituteInPlace setup.py --replace "use_scm_version=custom_version" "version='${version}'"
  '';

  # extraCheckInputs = [
  #   coverage
  #   cvxopt
  #   cvxpy # TODO: in nixpkgs/master, not in release yet.
  #   cython
  #   matplotlib
  #   mpi4py
  #   msgpack
  #   pandas
  #   psutil
  #   pyzmq
  #   jinja2
  # ];

  pythonImportsCheck = [
    "pygsti"
    "pygsti.algorithms"
    "pygsti.drivers"
    "pygsti.extras"
    "pygsti.io"
    "pygsti.modelpacks"
    "pygsti.objects"
    "pygsti.optimize"
    "pygsti.protocols"
    "pygsti.report"
    "pygsti.tools"
  ];

  checkInputs = [ nose nose-timer rednose cvxpy ];
  dontUseSetuptoolsCheck = true;

  # Run tests from temp directory to avoid nose finding un-cythonized code
  preCheck = ''
    export TESTDIR=$(mktemp -d)
    cp -r test/ $TESTDIR
    pushd $TESTDIR
  '';
  checkPhase = ''
    runHook preCheck

    nosetests test/unit -v --detailed-errors

    runHook postCheck
  '';
  postCheck = ''
    popd
  '';

  meta = with lib; {
    description = "A python implementation of quantum Gate Set Tomography";
    homepage = "http://www.pygsti.info";
    downloadPage = "https://www.github.com/pyGSTio/pyGSTi/releases";
    license = licenses.asl20;
    # maintainers = with maintainers; [ drewrisinger ];
  };
}
