{ lib
, rustPlatform
, python
, fetchFromGitHub
, pipInstallHook
, maturin
, pip
  # Check inputs
, pytestCheckHook
, numpy
}:

rustPlatform.buildRustPackage rec {
  pname = "retworkx";
  version = "0.6.0";

  # TODO: remove when 20.09 released, needed to build on CI.
  cargoSha256 = if
    lib.versionOlder lib.trivial.release "20.09"
    then "0bnkwp6ggcjd1j273hhww2ikgx9y62182pl55ijiijr963fq7bif"
    else "1vg4yf0k6yypqf9z46zz818mz7fdrgxj7zl6zjf7pnm2r8mq3qw5";
  legacyCargoFetcher = true;  # TODO: Remove on next nixos release. Cargo SHA mismatch b/w unstable & release.

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "retworkx";
    rev = version;
    sha256 = "11n30ldg3y3y6qxg3hbj837pnbwjkqw3nxq6frds647mmmprrd20";
  };

  propagatedBuildInputs = [ python ];

  nativeBuildInputs = [ pipInstallHook maturin pip ];

  # Needed b/c need to check AFTER python wheel is installed (using Rust Build, not buildPythonPackage)
  doCheck = false;
  doInstallCheck = true;

  installCheckInputs = [ pytestCheckHook numpy ];

  buildPhase = ''
    runHook preBuild
    maturin build --release --manylinux off --strip
    runHook postBuild
  '';

  installPhase = ''
    install -Dm644 -t dist target/wheels/*.whl
    pipInstallPhase
  '';

  preCheck = ''
    export TESTDIR=$(mktemp -d)
    cp -r tests/ $TESTDIR
    pushd $TESTDIR
  '';
  postCheck = "popd";


  meta = with lib; {
    description = "A python graph library implemented in Rust.";
    homepage = "https://retworkx.readthedocs.io/en/latest/index.html";
    downloadPage = "https://github.com/Qiskit/retworkx/releases";
    changelog = "https://github.com/Qiskit/retworkx/releases/tag/${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
