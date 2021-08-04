{ stdenv
, lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
# nixpkgs <= 20.09
, google_api_core ? null
# nixpkgs >= 20.09
, google-api-core ? null
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
  # Contrib requirements
, withContribRequires ? false
, autoray ? null
, opt-einsum
, ply
, pylatex ? null
, pyquil ? null
, quimb ? null
  # test inputs
, pytestCheckHook
, freezegun
, pytest-asyncio
}:

let
  version = "0.11.1";
  src = fetchFromGitHub {
    owner = "quantumlib";
    repo = "cirq";
    rev = "v${version}";
    sha256 = "sha256-Me+fhz/r5exG4jFaB8XRebQU187KZtbkRTa4VdwV+cg=";
  };
  disabled = pythonOlder "3.6";
  cirq-core = buildPythonPackage rec {
    pname = "cirq-core";
    inherit version src disabled;

    sourceRoot = "source/${pname}";

    postPatch = ''
      substituteInPlace requirements.txt \
        --replace "matplotlib~=3.0" "matplotlib" \
        --replace "networkx~=2.4" "networkx" \
        --replace "numpy~=1.16" "numpy" \
        --replace "requests~=2.18" "requests"
    '';

    propagatedBuildInputs = [
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
    dontUseSetuptoolsCheck = true;

    pytestFlagsArray = [
      "-rfE"
      # "--durations=10"
    ] ++ lib.optionals (!withContribRequires) [
      # requires external (unpackaged) libraries, so untested.
      "--ignore=cirq/contrib/"
    ];
    disabledTests = [
      "test_metadata_search_path" # tries to import flynt, which isn't in Nixpkgs
      "test_benchmark_2q_xeb_fidelities" # fails due pandas MultiIndex. Maybe issue with pandas version in nix?
    ] ++ lib.optionals stdenv.hostPlatform.isAarch64 [
      # Seem to fail due to math issues on aarch64?
      "expectation_from_wavefunction"
      "test_single_qubit_op_to_framed_phase_form_output_on_example_case"
    ];

    meta = with lib; {
      description = "A framework for creating, editing, and invoking Noisy Intermediate Scale Quantum (NISQ) circuits.";
      homepage = "https://github.com/quantumlib/cirq";
      changelog = "https://github.com/quantumlib/Cirq/releases/tag/v${version}";
      license = licenses.asl20;
      maintainers = with maintainers; [ drewrisinger ];
    };
  };
  cirq-google = buildPythonPackage rec {
    pname = "cirq-google";
    inherit version src disabled;
    sourceRoot = "source/${pname}";
    inherit (cirq-core) meta;

    postPatch = ''
      substituteInPlace requirements.txt --replace "protobuf~=3.13.0" "protobuf"
    '';

    propagatedBuildInputs = [
      cirq-core
      google_api_core
      google-api-core
      protobuf
    ];

    dontUseSetuptoolsCheck = true;
    checkInputs = [ pytestCheckHook freezegun ];
    disabledTests = lib.optionals (lib.versionOlder protobuf.version "3.9.0") [
      "engine_job_test"
      "test_health"
      "test_run_delegation"
    ];
  };
  cirq = buildPythonPackage rec {
    pname = "cirq";
    inherit version src disabled;

    preCheck = ''
      rm -rf cirq-core
      rm -rf cirq-google
    '';

    propagatedBuildInputs = [
      cirq-core
      cirq-google
    ];

    dontUseSetuptoolsCheck = true;
    checkInputs = [ pytestCheckHook ];
    pytestFlagsArray = [
      "--ignore=dev_tools"
    ];

    inherit (cirq-core) meta;
  };
in
assert (lib.versionOlder lib.trivial.release "21.05") -> google_api_core != null && google-api-core == null;
assert (lib.versionAtLeast lib.trivial.release "21.05") -> google-api-core != null && google_api_core == null;
{
  inherit cirq cirq-core cirq-google;
}
