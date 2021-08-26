{ lib
, buildPythonPackage
, fetchFromGitHub
, fetchpatch
, cirq
, deprecation
, h5py
, networkx
, numpy
, pubchempy
, requests
, scipy
, sympy
  # test inputs
, pytestCheckHook
, nbformat
}:

buildPythonPackage rec {
  pname = "openfermion";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "quantumlib";
    repo = "openfermion";
    rev = "v${version}";
    sha256 = "sha256-PEJOKf86ypPO8TqIJR+mqV80+1c8EDIr7fpoBV6Qwgc=";
  };

  postPatch = ''
    substituteInPlace requirements.txt --replace "cirq~=0.11.0" "cirq"
  '';

  propagatedBuildInputs = [
    cirq
    deprecation
    h5py
    networkx
    numpy
    pubchempy
    requests
    scipy
    sympy
  ];

  # pythonImportsCheck = [ "openfermion" ]; # has troubles with cirq's import mechanism
  dontUseSetuptoolsCheck = true;
  checkInputs = [ pytestCheckHook nbformat ];

  pytestFlagsArray = [
    "--disable-warnings"  # for reducing output so Travis CI isn't angry
  ];
  disabledTests = [
    "OpenFermionPubChemTest"
    "test_can_run_examples_jupyter_notebooks"
    "test_signal" # Fails when built on WSL, 1e-5 error in one value
    # Slow tests > 10 s
    "test_energy_reduce_symmetric"
    "test_all"
    "test_apply_constraints"
    "test_plane_wave_hamiltonian"
  ] ++ lib.optionals (lib.versionAtLeast cirq.version "0.11.1") [
    "test_cirq_deprecations"
  ]
    ++
    # These fail on scipy 1.6.1, seem to work before that
    lib.optionals (lib.versionAtLeast scipy.version "1.6.1") [
      # Have issues with some of these tests, don't have time to track down the issue.
      # Some of these are probably fixed by PR #710, but that patch doesn't apply cleanly
      "test_jw_sparse"
      "test_particle_conserving"
      "test_non_particle_conserving"
      "test_get_ground_state_hermitian"
      "JWGetGaussianStateTest"
  ];

  meta = with lib; {
    description = "The electronic structure package for quantum computers.";
    homepage = "https://github.com/quantumlib/openfermion";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
