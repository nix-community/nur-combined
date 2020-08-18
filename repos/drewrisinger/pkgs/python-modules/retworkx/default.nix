{ lib
, rustPlatform
, python
, fetchFromGitHub
, pipInstallHook
, maturin
, pip
  # Check inputs
, pytest
, numpy
}:

rustPlatform.buildRustPackage rec {
  pname = "retworkx";
  version = "0.4.0";

  # TODO: remove when 20.09 released, needed to build on CI.
  cargoSha256 = if
    lib.versionOlder lib.trivial.release "20.09"
    then "17zx3zl8aq9ga5xzgg6llszha4hchcwafg5nfgw0pzqn4pasvj8d"
    else "0axj6gxfc61nlbp9wzbragkhrxckbr1mjsny3ll8w0fl9j5p49fi";
  cargoPatches = [ ./cargo-lock.patch ];  # TODO: remove on next retworkx release, PR'd in PR#104
  legacyCargoFetcher = true;  # TODO: Remove on next nixos release. Cargo SHA mismatch b/w unstable & release.

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "retworkx";
    rev = version;
    sha256 = "1xqp6d39apkjvd0ad9vw81cp2iqzhpagfa4p171xqm3bwfn2imdc";
  };

  propagatedBuildInputs = [ python ];

  nativeBuildInputs = [ pipInstallHook maturin pip ];

  # Needed b/c need to check AFTER python wheel is installed (using Rust Build, not buildPythonPackage)
  doCheck = false;
  doInstallCheck = true;

  installCheckInputs = [ pytest numpy ];

  buildPhase = ''
    runHook preBuild
    maturin build --release --manylinux off --strip
    runHook postBuild
  '';

  installPhase = ''
    install -Dm644 -t dist target/wheels/*.whl
    pipInstallPhase
  '';

  # Called checkPhase for compatibility, but must be run after install (as installCheckPhase)
  installCheckPhase = ''
    pytest --import-mode=append
  '';

  meta = with lib; {
    description = "A python graph library implemented in Rust.";
    homepage = "https://retworkx.readthedocs.io/en/latest/index.html";
    downloadPage = "https://github.com/Qiskit/retworkx/releases";
    changelog = "https://github.com/Qiskit/retworkx/releases/tag/${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
