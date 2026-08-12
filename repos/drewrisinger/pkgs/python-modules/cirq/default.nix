{ stdenv
, lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, fetchpatch
, duet
, google-api-core
, matplotlib
, networkx
, numpy
, pandas
, protobuf
, requests
, scipy
, sortedcontainers
, sympy
, tqdm
, typing-extensions
  # , idna
, attrs
, httpcore
, httpx
, pyjwt
, pyquil
, pyRFC3339
, retrying
, toml
  # Contrib requirements
, withContribRequires ? false
, autoray ? null
, opt-einsum
, ply
, pylatex ? null
, quimb ? null
  # test inputs
, pytestCheckHook
, freezegun
, pytest-asyncio
}:

let
  version = "0.14.1";
  src = fetchFromGitHub {
    owner = "quantumlib";
    repo = "cirq";
    rev = "v${version}";
    sha256 = "sha256-cIDwV3IBXrTJ4jC1/HYmduY3tLe/f6wj8CWZ4cnThG8=";
  };
  disabled = pythonOlder "3.6";
  cirqSubPackage = { pname, ... } @ args: buildPythonPackage ((builtins.removeAttrs args [ ]) // rec {
    inherit pname version src disabled;
    sourceRoot = "source/${pname}";

    propagatedBuildInputs = if pname != "cirq-core" then ((args.propagatedBuildInputs or [ ]) ++ [ cirq-core ]) else args.propagatedBuildInputs;

    checkInputs = args.checkInputs or [ pytestCheckHook ];
    meta = args.meta or cirq-core.meta;
  }
  );
  cirq-core = cirqSubPackage {
    pname = "cirq-core";
    postPatch = ''
      substituteInPlace requirements.txt \
        --replace "matplotlib~=3.0" "matplotlib" \
        --replace "networkx~=2.4" "networkx" \
        --replace "numpy~=1.16" "numpy" \
        --replace "sympy<1.10" "sympy"

      # test was written to expect the dev version, but fails when built against the release version
    '';

    propagatedBuildInputs = [
      duet
      matplotlib
      networkx
      numpy
      pandas
      requests
      scipy
      sortedcontainers
      sympy
      tqdm
      typing-extensions
    ] ++ lib.optionals withContribRequires [
      autoray
      opt-einsum
      ply
      pylatex
      pyquil
      quimb
    ];

    checkInputs = [
      pytestCheckHook
      pytest-asyncio
      freezegun
    ];

    pytestFlagsArray = [
      "-rfE"
      "--durations=10"
      # "-x"
    ] ++ lib.optionals (!withContribRequires) [
      # requires external (unpackaged) libraries, so untested.
      "--ignore=cirq/contrib/"
    ];
    disabledTests = [
      "test_metadata_search_path" # tries to import flynt, which isn't in Nixpkgs
      "test_benchmark_2q_xeb_fidelities" # fails due pandas MultiIndex. Maybe issue with pandas version in nix?
      "test_qasm" # in cirq/ops/classically_controlled_operations_test.py, fails due to string header including dev version number
    ] ++ [
      # slow tests, >10 seconds locally
      "test_fsim_gate_with_symbols"
      "test_controlled_operation_is_consistent"
      "test_merge_operations_complexity"
      "test_incremental_simulate"
    ] ++ lib.optionals (lib.versionAtLeast scipy.version "1.6.0") [
      "test_projector_matrix_missing_qid"
      "test_projector_from_np_array"
      "test_projector_matrix"
      "test_projector_sum"
    ] ++ lib.optionals stdenv.hostPlatform.isAarch64 [
      # Seem to fail due to math issues on aarch64?
      "expectation_from_wavefunction"
      "test_single_qubit_op_to_framed_phase_form_output_on_example_case"
    ];

    meta = with lib; {
      description = "A framework for creating, editing, and invoking Noisy Intermediate Scale Quantum (NISQ) circuits.";
      homepage = "https://quantumai.google/cirq";
      downloadPage = "https://github.com/quantumlib/cirq";
      changelog = "https://github.com/quantumlib/Cirq/releases/tag/v${version}";
      license = licenses.asl20;
      maintainers = with maintainers; [ drewrisinger ];
    };
  };
  cirq-google = cirqSubPackage {
    pname = "cirq-google";
    postPatch = ''
      substituteInPlace requirements.txt \
        --replace "protobuf~=3.13.0" "protobuf" \
        --replace "google-api-core[grpc] >= 1.14.0, < 2.0.0dev" "google-api-core[grpc] >= 1.14.0, < 3.0.0dev"
    '';

    propagatedBuildInputs = [
      cirq-core
      google-api-core
      protobuf
    ];

    checkInputs = [ pytestCheckHook freezegun ];
    disabledTests = lib.optionals (lib.versionOlder protobuf.version "3.9.0") [
      "engine_job_test"
      "test_health"
      "test_run_delegation"
    ];
  };
  cirq-aqt = cirqSubPackage {
    pname = "cirq-aqt";
  };
  cirq-ionq = cirqSubPackage {
    pname = "cirq-ionq";
  };
  cirq-rigetti = cirqSubPackage {
    pname = "cirq-rigetti";
    postPatch = ''
      substituteInPlace requirements.txt \
        --replace 'pyquil~=3.0.0; python_version >= "3.7"' 'pyquil' \
        --replace 'pyquil~=2.28.2; python_version < "3.7"' ''' \
        --replace "rfc3339~=6.2" "rfc3339" \
        --replace "toml~=0.10.2" "toml" \
        --replace "six~=1.16.0" "six" \
        --replace "rfc3986~=1.5.0" "rfc3986" \
        --replace "httpcore~=0.11.1" "httpcore" \
        --replace "pydantic~=1.8.2" "pydantic" \
        --replace "sniffio~=1.2.0" "sniffio" \
        --replace "certifi~=2021.5.30" "certifi" \
        --replace "attrs~=20.3.0" "attrs" \
        --replace "httpx~=0.15.5" "httpx" \
        --replace "iso8601~=0.1.14" "iso8601" \
        --replace "~=" ">="
    '' + lib.optionalString (lib.versionAtLeast httpcore.version "0.14.1") ''
      substituteInPlace cirq_rigetti/service_test.py \
        --replace "from httpcore._types import URL, Headers" "" \
        --replace ": URL" "" \
        --replace ": Headers" ""
    '';
    propagatedBuildInputs = [
      # idna
      attrs
      httpcore
      httpx
      pyjwt
      pyRFC3339
      pyquil
      retrying
      toml
    ];
  };
  cirq-pasqal = cirqSubPackage {
    pname = "cirq-pasqal";
  };
  cirq-web = cirqSubPackage {
    pname = "cirq-web";
  };
  cirq = buildPythonPackage rec {
    pname = "cirq";
    inherit version src disabled;

    patches = [
      (fetchpatch {
        url = "https://github.com/quantumlib/Cirq/commit/b832db606e5f1850b1eda168a6d4a8e77d8ec711.patch";
        name = "pr-5330-prevent-implicit-packages.patch";
        sha256 = "sha256-HTEH3fFxPiBedaz5GxZjXayvoiazwHysKZIOzqwZmbg=";
      })
    ];

    preCheck = ''
      rm -rf cirq-aqt
      rm -rf cirq-core
      rm -rf cirq-google
      rm -rf cirq-ionq
      rm -rf cirq-rigetti
      rm -rf cirq-pasqal
      rm -rf cirq-web
    '';

    propagatedBuildInputs = [
      cirq-aqt
      cirq-core
      cirq-google
      cirq-ionq
      cirq-pasqal
      cirq-rigetti
      cirq-web
    ];

    checkInputs = [ pytestCheckHook ];
    pytestFlagsArray = [
      "--ignore=dev_tools"
    ];

    inherit (cirq-core) meta;
  };
in
{
  inherit
    cirq
    cirq-aqt
    cirq-core
    cirq-google
    cirq-ionq
    cirq-pasqal
    cirq-rigetti
    cirq-web
    ;
}
