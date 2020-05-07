{ stdenv
, lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, fetchpatch
, freezegun
, google_api_core
, matplotlib
, networkx
, numpy
, pandas
, pythonProtobuf  # pythonPackages.protobuf
, requests
, scipy
, sortedcontainers
, sympy
, typing-extensions
  # test inputs
, pytestCheckHook
, pytest-asyncio
, pytest-benchmark
, ply
, pydot
, pyyaml
, pygraphviz
}:

buildPythonPackage rec {
  pname = "cirq";
  version = "0.8.0";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "quantumlib";
    repo = "cirq";
    rev = "v${version}";
    sha256 = "01nnv7r595sp60wvp7750lfdjwdsi4q0r4lmaj6li09zsdw0r4b3";
  };

  # Cirq locks protobuf==3.8.0, but tested working with default pythonPackages.protobuf (3.7). This avoids overrides/pythonPackages.protobuf conflicts
  postPatch = ''
    substituteInPlace requirements.txt \
      --replace "networkx~=2.4" "networkx" \
      --replace "protobuf==3.8.0" "protobuf" \
      --replace "freezegun~=0.3.15" "freezegun"
  '';

  propagatedBuildInputs = [
    freezegun
    google_api_core
    numpy
    matplotlib
    networkx
    pandas
    pythonProtobuf
    requests
    scipy
    sortedcontainers
    sympy
    typing-extensions
  ];

  doCheck = true;
  # pythonImportsCheck = [ "cirq" "cirq.Ciruit" ];  # cirq's importlib hook doesn't work here
  dontUseSetuptoolsCheck = true;
  checkInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-benchmark
    ply
    pydot
    pyyaml
    pygraphviz
  ];

  # TODO: enable op_serializer_test. Error is type checking, for some reason wants bool instead of numpy.bool_. Not sure if protobuf or internal issue
  pytestFlagsArray = [
    "--ignore=dev_tools"  # Only needed when developing new code, which is out-of-scope
    # "--ignore=cirq/google/op_serializer_test.py"  # investigating in https://github.com/quantumlib/Cirq/issues/2727
    "--disable-warnings"  # warnings take too many lines, mostly just warning that Qiskit isn't installed so can't cross-verify. Guards against travis build errors (too many log lines)
    "-rfE"
  ];
  disabledTests = [
    "test_serialize_sympy_constants"  # fails due to small error in pi (~10e-7)
    "test_serialize_conversion" # same failure mechanism as op_serializer_test
    "test_convert_to_ion_gates" # fails due to rounding error, 0.75 != 0.750...2
    "val_type5-val5-arg_value5" # from op_serializer_test, just disable the bool value.

    # Newly disabled tests on cirq 0.8
    # TODO: test & figure out why failing
    "engine_job_test"
    "test_health"
    "test_run_delegation"
  ] ++ lib.optionals stdenv.isAarch64 [
    # Seem to fail due to math issues on aarch64?
    "expectation_from_wavefunction"
    "test_single_qubit_op_to_framed_phase_form_output_on_example_case"
  ];

  meta = with lib; {
    description = "A framework for creating, editing, and invoking Noisy Intermediate Scale Quantum (NISQ) circuits.";
    homepage = "https://github.com/quantumlib/cirq";
    license = licenses.asl20;
    # maintainers = with maintainers; [ drewrisinger ];
  };
}
