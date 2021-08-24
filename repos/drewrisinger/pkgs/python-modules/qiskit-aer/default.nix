{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, fetchpatch
  # C Inputs
, blas
, openblas
, catch2
, cmake
, cython
, fmt
, muparserx
, ninja
, nlohmann_json
, spdlog
  # Python Inputs
, cvxpy
, numpy
, pybind11
, scikit-build
  # Check Inputs
, pytestCheckHook
, ddt
, fixtures
, qiskit-terra
, setuptools
, testtools
}:

buildPythonPackage rec {
  pname = "qiskit-aer";
  version = "0.8.2";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "qiskit-aer";
    rev = version;
    sha256 = "1zcm0bdy40y0c49ycwb1qwyfq64hwx1q87cxxb07nhscmbp8rmgc";
  };

  patches = [
    (fetchpatch {
      # Merged, not on stable: https://github.com/Qiskit/qiskit-aer/pull/1250
      name = "qiskit-aer-pr-1250-native-cmake_dl_libs.patch";
      url = "https://github.com/Qiskit/qiskit-aer/commit/2bf04ade3e5411776817706cf82cc67a3b3866f6.patch";
      sha256 = "0ldwzxxfgaad7ifpci03zfdaj0kqj0p3h94qgshrd2953mf27p6z";
    })
    (fetchpatch {
      # Merged, not yet on stable: https://github.com/Qiskit/qiskit-aer/pull/1262
      name = "qiskit-aer-pr-1262-fix-tests.patch";
      url = "https://github.com/Qiskit/qiskit-aer/commit/91c8990c9d9950df3e1338c11ed46645a7778911.patch";
      sha256 = "1bgys17srjwh9arzqy6nrxbw8np9nxbcikzcidr8lyy4s1ngpag0";
    })
    (fetchpatch {
      # Merged, but not yet on stable:
      name = "qiskit-aer-pr-1292-fix-terra-dependent-tests.patch";
      url = "https://github.com/Qiskit/qiskit-aer/commit/224b8755b1d85634a754756cd542e604dc4081fd.patch";
      sha256 = "0njdfna6v7ijancgpxg5nrvajf7ax6j6441v2pkqgjabcjc73k1f";
    })
  ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace "'cmake!=3.17,!=3.17.0'," "" \
      --replace "'pybind11', min_version='2.6'" "'pybind11'" \
      --replace "pybind11>=2.6" "pybind11" \
      --replace "scikit-build>=0.11.0" "scikit-build" \
      --replace "min_version='0.11.0'" ""
  '';

  nativeBuildInputs = [
    cmake
    ninja
    scikit-build
  ];

  buildInputs = [
    (if (lib.versionAtLeast lib.version "20.09") then blas else openblas )
    catch2
    nlohmann_json
    fmt
    muparserx
    spdlog
  ];

  propagatedBuildInputs = [
    cvxpy
    cython  # generates some cython files at runtime that need to be cython-ized
    numpy
    pybind11
  ];

  preBuild = ''
    export DISABLE_CONAN=1
  '';

  dontUseCmakeConfigure = true;

  # *** Testing ***
  pythonImportsCheck = [
    "qiskit.providers.aer"
    "qiskit.providers.aer.backends.qasm_simulator"
    "qiskit.providers.aer.backends.controller_wrappers" # Checks C++ files built correctly. Only exists if built & moved to output
  ];
  pytestFlagsArray = [ "--durations=10" ];
  disabledTests = [
    # these fail for some builds. Haven't been able to reproduce error locally.
    "test_kraus_gate_noise"
    "test_backend_method_clifford_circuits_and_kraus_noise"
    "test_backend_method_nonclifford_circuit_and_kraus_noise"
    "test_kraus_noise_fusion"

    # Slow tests
    "test_paulis_1_and_2_qubits"
    "test_3d_oscillator"
    "_057"
    "_136"
    "_137"
    "_139"
    "_138"
    "_140"
    "_141"
    "_143"
    "_144"
    "test_sparse_output_probabilities"
    "test_reset_2_qubit"
  ] ++ lib.optionals (lib.versionAtLeast cvxpy.version "1.1.15") [
    "test_clifford"
  ];
  checkInputs = [
    pytestCheckHook
    ddt
    fixtures
    qiskit-terra
    setuptools  # temporary workaround for pbr missing setuptools, see https://github.com/NixOS/nixpkgs/pull/132614
    testtools
  ];
  dontUseSetuptoolsCheck = true;  # Otherwise runs tests twice

  preCheck = ''
    # Tests include a compiled "circuit" which is auto-built in $HOME
    export HOME=$(mktemp -d)
    # move tests b/c by default try to find (missing) cython-ized code in /build/source dir
    cp -r $TMP/$sourceRoot/test $HOME

    # Add qiskit-aer compiled files to cython include search
    pushd $HOME
    # TODO: remove this in next release. This logic is no longer necessary after https://github.com/Qiskit/qiskit-terra/pull/6753
    export QISKIT_TEST_CAPTURE_STREAMS=1
  '';
  postCheck = "popd";

  meta = with lib; {
    description = "High performance simulators for Qiskit";
    homepage = "https://qiskit.org/aer";
    downloadPage = "https://github.com/QISKit/qiskit-aer/releases";
    changelog = "https://qiskit.org/documentation/release_notes.html";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
