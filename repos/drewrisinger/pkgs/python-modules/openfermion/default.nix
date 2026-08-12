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
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "quantumlib";
    repo = "openfermion";
    rev = "v${version}";
    sha256 = "sha256-XrzB79PPCou5gWwbrCszH316U2wDc712kTwtQFBCPOw=";
  };


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
  ] ++ lib.optionals (lib.versionAtLeast cirq.version "0.14.0") [
    # these fail for some reason on cirq 0.14.0. Reported in https://github.com/quantumlib/OpenFermion/issues/775
    "test_fermionic_simulation_gate"
    "test_quartic_fermionic_simulation_consistency"
  ];

  meta = with lib; {
    description = "The electronic structure package for quantum computers.";
    homepage = "https://github.com/quantumlib/openfermion";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
