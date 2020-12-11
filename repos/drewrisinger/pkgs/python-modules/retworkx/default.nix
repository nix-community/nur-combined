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
  version = "0.7.1";

  # TODO: remove when 20.09 released, needed to build on CI.
  cargoSha256 = if
    lib.versionOlder lib.trivial.release "20.09"
    then "1xjr3h93lcq9l1g2qpaxyrqp5ji27s85zf4a7qmfrrrvkkimv6w4"
    else "044ahfrrcnw81yb2him7vgxsx7lx7fdhk0zakr283l1czb52an5r";
  legacyCargoFetcher = true;  # TODO: Remove on next nixos release. Cargo SHA mismatch b/w unstable & release.

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "retworkx";
    rev = version;
    sha256 = "09cxq714b6myxyak4xsp7g9sgpsl43l0g0wy58snih0jfvkh06dn";
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
