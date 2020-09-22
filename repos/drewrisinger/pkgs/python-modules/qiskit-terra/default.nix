{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
  # Python requirements
, cython
, dill
, fastjsonschema
, jsonschema
, numpy
, networkx
, ply
, psutil
, python-constraint
, python-dateutil
, retworkx
, scipy
, sympy
, withVisualization ? true
  # Python visualization requirements, semi-optional
, ipywidgets
, matplotlib
, pillow
, pydot
, pygments
, pylatexenc
, seaborn
  # Crosstalk-adaptive layout pass
, withCrosstalkPass ? false
, z3
  # test requirements
, ddt
, hypothesis
, nbformat
, nbconvert
, pytestCheckHook
, python
}:

let
  visualizationPackages = [
    ipywidgets
    matplotlib
    pillow
    pydot
    pygments
    pylatexenc
    seaborn
  ];
  crosstalkPackages = [ z3 ];
in

buildPythonPackage rec {
  pname = "qiskit-terra";
  version = "0.15.2";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = pname;
    rev = version;
    sha256 = "12a3x5gz66mrqxm3lwhv0zfzhzyazz0xfgsgbbhffw5pvmy52fs8";
  };

  nativeBuildInputs = [ cython ];

  propagatedBuildInputs = [
    dill
    fastjsonschema
    jsonschema
    numpy
    networkx
    ply
    psutil
    python-constraint
    python-dateutil
    retworkx
    scipy
    sympy
  ] ++ lib.optional withVisualization visualizationPackages
  ++ lib.optional withCrosstalkPass crosstalkPackages;


  # *** Tests ***
  checkInputs = [
    pytestCheckHook
    ddt
    hypothesis
    nbformat
    nbconvert
  ] ++ visualizationPackages;
  dontUseSetuptoolsCheck = true;  # can't find setup.py, so fails. tested by pytest

  pythonImportsCheck = [
    "qiskit"
    "qiskit.transpiler.passes.routing.cython.stochastic_swap.swap_trial"
  ];

  pytestFlagsArray = [
    "--ignore=test/randomized/test_transpiler_equivalence.py" # collection requires qiskit-aer, which would cause circular dependency
  ];
  disabledTests = [
    # Flaky tests
    "test_pulse_limits" # Fails on GitHub Actions, probably due to minor floating point arithmetic error.
  ]
  # Disabling slow tests for Travis build constraints
  ++ [
    "test_all_examples"
    "test_controlled_random_unitary"
    "test_controlled_standard_gates_1"
    "test_jupyter_jobs_pbars"
    "test_lookahead_swap_higher_depth_width_is_better"
    "test_move_measurements"
    "test_job_monitor"
    "test_wait_for_final_state"
    "test_multi_controlled_y_rotation_matrix_basic_mode"
    "test_two_qubit_weyl_decomposition_abc"
    "test_isometry"
    "test_parallel"
    "test_random_state"
  ];

  # Moves tests to $PACKAGEDIR/test. They can't be run from /build because of finding
  # cythonized modules and expecting to find some resource files in the test directory.
  preCheck = ''
    export PACKAGEDIR=$out/${python.sitePackages}
    echo "Moving Qiskit test files to package directory"
    cp -r $TMP/source/test $PACKAGEDIR
    cp -r $TMP/source/examples $PACKAGEDIR
    cp -r $TMP/source/qiskit/schemas/examples $PACKAGEDIR/qiskit/schemas/

    # run pytest from Nix's $out path
    pushd $PACKAGEDIR
  '';
  postCheck = ''
    rm -rf test
    rm -rf examples
    popd
  '';


  meta = with lib; {
    description = "Provides the foundations for Qiskit.";
    longDescription = ''
      Allows the user to write quantum circuits easily, and takes care of the constraints of real hardware.
    '';
    homepage = "https://qiskit.org/terra";
    downloadPage = "https://github.com/QISKit/qiskit-terra/releases";
    changelog = "https://qiskit.org/documentation/release_notes.html";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
