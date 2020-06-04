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
  version = "0.8.1";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "quantumlib";
    repo = "cirq";
    rev = "v${version}";
    sha256 = "12695042a75pzgqfqjb84n3qm25zgz74qh3cqifdbc9adasz5gr8";
  };

  patches = [
    (fetchpatch {
      name = "cirq-pr-2986-protobuf-bools.patch";
      url = "https://github.com/quantumlib/Cirq/commit/78ddfb574c0f3936f713613bf4ba102163efb7b3.patch";
      sha256 = "0hmad9ndsqf5ci7shvd924d2rv4k9pzx2r2cl1bm5w91arzz9m18";
    })
  ];

  # Cirq locks protobuf==3.8.0, but tested working with default pythonPackages.protobuf (3.7). This avoids overrides/pythonPackages.protobuf conflicts
  postPatch = ''
    substituteInPlace requirements.txt \
      --replace "networkx~=2.4" "networkx" \
      --replace "protobuf==3.8.0" "protobuf" \
      --replace "freezegun~=0.3.15" "freezegun"

    # Fix serialize_sympy_constants test (#2728) by allowing small errors in pi
    substituteInPlace cirq/google/arg_func_langs_test.py \
      --replace "{'arg_value': {'float_value': float(np.float32(sympy.pi))}}" "{'arg_value': pytest.approx({'float_value': float(np.float32(sympy.pi))})}"
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
    "--disable-warnings"  # warnings take too many lines, mostly just warning that Qiskit isn't installed so can't cross-verify. Guards against travis build errors (too many log lines)
    "-rfE"
  ];
  disabledTests = [
    "test_convert_to_ion_gates" # fails due to rounding error, 0.75 != 0.750...2

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
