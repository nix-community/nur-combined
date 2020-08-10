{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, fetchpatch
, cmake
, cvxpy
, cython
, muparserx
, ninja
, nlohmann_json
, numpy
, openblas
, pybind11
, scikit-build
, spdlog
  # Check Inputs
, qiskit-terra
, pytestCheckHook
, python
}:

buildPythonPackage rec {
  pname = "qiskit-aer";
  version = "0.6.1";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "qiskit-aer";
    rev = version;
    sha256 = "1fnv11diis0as8zcc57mamz0gbjd6vj7nw3arxzvwa77ja803sr4";
  };

  nativeBuildInputs = [
    cmake
    ninja
    scikit-build
  ];

  buildInputs = [
    openblas
    spdlog
    nlohmann_json
    muparserx
  ];

  propagatedBuildInputs = [
    cvxpy
    cython  # generates some cython files at runtime that need to be cython-ized
    numpy
    pybind11
  ];

  patches = [
    ./remove-conan-install.patch
  ];

  dontUseCmakeConfigure = true;

  # Needed to find qiskit.providers.aer modules in cython. This exists in GitHub, don't know why it isn't copied by default
  # postFixup = ''
  #   touch $out/${python.sitePackages}/qiskit/__init__.pxd
  # '';

  # *** Testing ***

  pythonImportsCheck = [
    "qiskit.providers.aer"
    "qiskit.providers.aer.backends.qasm_simulator"
    "qiskit.providers.aer.backends.controller_wrappers" # Checks C++ files built correctly. Only exists if built & moved to output
  ];
  checkInputs = [
    qiskit-terra
    pytestCheckHook
  ];
  dontUseSetuptoolsCheck = true;  # Otherwise runs tests twice

  pytestFlagsArray = [
    # Disabled b/c taking too many log lines in Travis
    "--disable-warnings"
  ];

  preCheck = ''
    # Tests include a compiled "circuit" which is auto-built in $HOME
    export HOME=$(mktemp -d)
    # move tests b/c by default try to find (missing) cython-ized code in /build/source dir
    cp -r $TMP/$sourceRoot/test $HOME

    # Add qiskit-aer compiled files to cython include search
    pushd $HOME
  '';
  postCheck = ''
    popd
  '';

  meta = with lib; {
    description = "High performance simulators for Qiskit";
    homepage = "https://qiskit.org/aer";
    downloadPage = "https://github.com/QISKit/qiskit-aer/releases";
    license = licenses.asl20;
    # maintainers = with maintainers; [ drewrisinger ];
    # Doesn't build on aarch64 (libmuparserx issue).
    # Can fix by building muparserx from source (https://github.com/beltoforion/muparserx)
    # or in future updates (e.g. Raspberry Pi enabled via https://github.com/Qiskit/qiskit-aer/pull/651 & https://github.com/Qiskit/qiskit-aer/pull/660)
    platforms = platforms.x86_64;
  };
}
