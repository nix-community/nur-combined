{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, cargo
, rustc
, semantic-version
, toml
, setuptools_scm
  # Check Inputs
, pytest
, pytest-benchmark
, lxml
, beautifulsoup4
}:

buildPythonPackage rec {
  pname = "setuptools-rust";
  version = "0.10.6";

  disabled = pythonOlder "3.5";

  # Pypi's tarball doesn't contain tests
  src = fetchFromGitHub {
    owner = "PyO3";
    repo = pname;
    rev = "v${version}";
    sha256 = "19q0b17n604ngcv8lq5imb91i37frr1gppi8rrg6s4f5aajsm5fm";
  };

  nativeBuildInputs = [
    setuptools_scm
  ];

  propagatedBuildInputs = [
    semantic-version
    toml
    rustc
    cargo
  ];

  doCheck = false;
  checkInputs = [
    pytest
    lxml
    pytest-benchmark
    beautifulsoup4
  ];
  # From CI build, doesn't work in Nix build b/c it requires downloading cargo crates
  checkPhase = ''
    pushd example_tomlgen
    python setup.py tomlgen_rust -w
    python setup.py build
    popd
    echo "example_tomlgen succeeded"
    pushd html-py-ever
    python setup.py build
    cd test
    pytest
    popd
  '';

  meta = with lib; {
    description = "Setuptools rust extension plugin";
    homepage = "https://github.com/PyO3/setuptools-rust";
    license = licenses.mit;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
