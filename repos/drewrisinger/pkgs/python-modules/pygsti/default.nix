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
  version = "0.9.9.3";

  src = fetchFromGitHub {
    owner = "pyGSTio";
    repo = pname;
    rev = "v${version}";
    sha256 = "1hadwcag8kqc0k0hnrg9bkn4d4z78llfmr11wh1g0zxyina5y3dq";
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
  disabledTests = [
    # Tests seem broken on CI, but build locally
    "test_diamonddist"
    "test_build_cloud_crosstalk_model_with_nonstd_gate_unitary_factory"
    "GateSetTomographyTester"
    "StandardGSTTester"
    "test_err_gen"
    "test_diamond_distance"

    # Disable slow tests
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
    # More slow tests 2020-06-29
    "test_circuit_layer_by_co2Qgates"
    "test_get_min_tree_size"
    "test_get_sub_trees"
    "test_chi2_fn"
    "test_chi2_terms"
    "test_bootstrap_utilities"
    "test_do_mc2gst_CPTP_SPAM_penalty_factor"
    "test_make_bootstrap_models_parametric"
    "test_hprobs"
    "test_log_diff_model_projection"
    "test_contract_with_bad_effect"
    "test_bulk_hprobs_by_block"
    "test_do_iterative_mc2gst_check_jacobian"
    "test_stdpractice_gst_file_args"
    "test_logGTi_model_projection"
    "test_logTiG_model_projection"
    "test_direct_mlgst_models"
    "test_do_mc2gst_SPAM_penalty_factor"
    "test_stdpractice_gst_gaugeOptTarget"
    "test_kcoverage"
    "test_split_on_num_subtrees"
    "test_stdpractice_gst_gaugeOptTarget_warns_on_target_override"
    "test_make_bootstrap_models_nonparametric"
    "test_direct_mc2gst_models"
  ];

  meta = with lib; {
    description = "A python implementation of quantum Gate Set Tomography";
    homepage = "http://www.pygsti.info";
    downloadPage = "https://www.github.com/pyGSTio/pyGSTi/releases";
    license = licenses.asl20;
    # maintainers = with maintainers; [ drewrisinger ];
  };
}
