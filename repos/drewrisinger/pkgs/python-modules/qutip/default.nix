{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, cython
, matplotlib
, numpy
, scipy
  # Test inputs
, pytestCheckHook
, ipython
}:

buildPythonPackage rec {
  pname = "qutip";
  version = "4.6.1";
  format = "pyproject";
  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "qutip";
    repo = "qutip";
    rev = "v${version}";
    sha256 = "0nr0amk6k07rrx1r8a2vsw390cw9fqr0g4ian4rx0r4x9nqmjy57";
  };

  propagatedBuildInputs = [
    cython
    matplotlib
    numpy
    scipy
  ];

  postPatch = ''
    substituteInPlace setup.cfg --replace "cython>=0.29.20" "cython"
  '';

  # Tell qutip build process that this is a release version
  preBuild = ''
    export CI_QUTIP_RELEASE=1
  '';

  pythonImportsCheck = [ "qutip" ];
  checkInputs = [ pytestCheckHook ipython ];
  dontUseSetuptoolsCheck = true;
  # copy qutip tests to a separate directory so pytest doesn't add $builddir/qutip to PATH,
  # which fails b/c the compiled libraries are missing
  preCheck = ''
    export HOME=$(mktemp -d)
    cp -r $TMP/$sourceRoot/qutip/tests $HOME
    pushd $HOME
  '';
  pytestFlagsArray = [
    "--durations=10"
    "-v"
    "-rfE"
  ];
  disabledTests = [
    # Slow tests, > 10s. All pass. Brings test time ~20 mins -> ~5 mins
    "test_MCSimpleConstStr"
    "test_compare_solvers_coherent_state_memc"
    "test_ssesolve_feedback"
    "test_QobjEvo_mul"
    "test_QobjEvo_call"
    "test_general_stochastic"
    "test_ssesolve_homodyne_methods"
    "test_smesolve_homodyne_methods"
    "testMEDecayAsStrList"
    "test_MCNoCollStr"
    "test_QobjEvo_expect"
    "test_QobjEvo_safepickle"
    "testMETDDecayAsStrList"
    "testPropHOStrTd"
    "test_04_1_state_with_list_str_H"
    "test_QobjEvo_with_state"
    "test_MCTDStr"
    "test_04_2_unitary_with_list_func_H"
    "test_06_4_compare_state_and_unitary_list_str"
    "test_array_str_coeff"
    "test_np_str_list_td_corr"
    "test_str_list_td_corr"
    "test_interpolate_evolve"
    "test_interpolate_brevolve1"
    "test_interpolate_brevolve2"
    "test_H_np_list_td_corr"
    "test_H_str_list_td_corr"
    "test_c_ops_str_list_td_corr"
    "test_smesolve_heterodyne"
    "test_angle_slicing"
    "test_csr_kron"
    "test_MCSimpleConstFunc"
    "test_03_dumping"
    "test_mc_seed_reuse"
    "test_MCSimpleConstStates"
    "test_mc_seed_noreuse"
    "test_06_lindbladian"
    "test_jaynes_cummings_zero_temperature"
    "test_hamiltonian_taking_arguments"
    "test_np_list_td_corr"
    "testScatteringProbability"
    "test_split_operators_maintain_answer"
    "test_wigner_ghz_su2parity"
    "test_smesolve_homodyne"
    "test_result_states"
  ];

  meta = with lib; {
    description = "Quantum Toolbox in Python.";
    homepage = "http://qutip.org";  # HTTPS not currently enabled
    downloadPage = "https://github.com/qutip/qutip/releases";
    changelog = "http://qutip.org/docs/latest/changelog.html";
    license = licenses.bsd3;
    maintainers = maintainers.drewrisinger;
  };
}
