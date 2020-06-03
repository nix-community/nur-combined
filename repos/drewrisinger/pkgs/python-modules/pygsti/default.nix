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
# , coverage
, cvxpy
, pytestCheckHook
, nose  # needed for test assert import
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
  version = "0.9.9.2";

  src = fetchFromGitHub {
    owner = "pyGSTio";
    repo = pname;
    rev = "v${version}";
    sha256 = "1pvd9i9sfna5wcr8wf12rzlg2qw9xdlvh2fr2037600l87008vnp";
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

  checkInputs = [ pytestCheckHook cvxpy nose ];
  dontUseSetuptoolsCheck = true;

  # Run tests from temp directory to avoid nose finding un-cythonized code
  preCheck = ''
    export TESTDIR=$(mktemp -d)
    cp -r $TMP/$sourceRoot/test/ $TESTDIR
    pushd $TESTDIR
  '';
  postCheck = "popd";
  pytestFlagsArray = [
    "./test/unit"
    # "-v"
    # "--durations=25"
    "--disable-warnings"  # reduce garbage lines from many tests throwing same warning
  ];
  # Disable slow tests
  disabledTests = [
    "CPTPGaugeOpt"
    "test_squeeze"
    "test_find_sufficient_fiducial_pairs"
    "test_long_sequence_gst"
    "test_stdpractice_gst_CPTP"
    "LGSTGaugeOpt"
    "test_grasp_germ_set_optimization"
    "test_focused_mc2gst_models"
    "GreedyGermSelection"
    "test_split_on_max_subtree_size"
    "test_logl_hessian"
    "test_add_gaugeoptimized"
    "test_generate_fake_data"
    "test_evaluation_order"
    "test_circuit_layer_by_Qelimination"
    "fiducial_pairs_from"
    "test_merge_outcomes"
    "optimize_integer_fiducials"
    "generate_germs_with_candidate_germ_counts" # runs especially slow on travis, probably due to random num generation
    "gauge_optimize_model_list"
    "test_final_slice"
  ];

  meta = with lib; {
    description = "A python implementation of quantum Gate Set Tomography";
    homepage = "http://www.pygsti.info";
    downloadPage = "https://www.github.com/pyGSTio/pyGSTi/releases";
    license = licenses.asl20;
    # maintainers = with maintainers; [ drewrisinger ];
  };
}
