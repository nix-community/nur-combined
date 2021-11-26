{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, autoray
, cytoolz
, opt-einsum
, psutil
, numba
, numpy
, scipy
, tqdm
, versioneer
  # Check Inputs
, pytestCheckHook
, matplotlib
, networkx
}:

buildPythonPackage rec {
  pname = "quimb";
  version = "1.3.0";

  disabled = pythonOlder "3.6";

  # Pypi's tarball doesn't contain tests
  src = fetchFromGitHub {
    owner = "jcmgray";
    repo = pname;
    rev = version;
    sha256 = "0ay1inb0zdn3wzzla33cfv698zbqjrxj0aym1i63hdam78fy1fn8";
  };

  propagatedBuildInputs = [
    autoray
    cytoolz
    opt-einsum
    psutil
    numba
    numpy
    scipy
    tqdm
    versioneer
  ];

  preCheck = ''
    substituteInPlace setup.cfg --replace "--cov=quimb --cov-report term-missing" ""
  '';
  checkInputs = [
    pytestCheckHook
    matplotlib
    networkx
  ];
  pytestFlagsArray = [
    "-rfE"
    "--ignore=tests/test_tensor/test_tensor_1d.py"
  ];
  disabledTests = [
    "test_special"

    # These fail on CI, but work locally. not sure why
    "test_rand_phase"
    "test_against_arpack"
    "test_unitize"
    "test_insert_gauge"
    "test_multisubsystem"

    # Slow tests
    "test_realistic_ent"
    "test_cyclic_solve_big_with_segmenting"
    "test_approx_fn"
    "test_estimate_rank"
    "test_OTOC_local"
    "test_ground_state_matches"
    "test_ising_model_with_field"
    "test_evolve_obc_pbc"
    "test_partial_trace_compress"
    "TestMPOSpectralApprox"
    "test_solve_bigger"
    "test_entropy_subsystem"
    "test_entropy_approx_many_body"
    "test_eigh"
    "test_matches_exact"
    "test_explicit_sweeps"
    "test_canonize_cyclic"
  ];

  meta = with lib; {
    description = "A library for quantum information and many-body calculations including tensor networks";
    homepage = "http://quimb.readthedocs.io/en/latest/";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
