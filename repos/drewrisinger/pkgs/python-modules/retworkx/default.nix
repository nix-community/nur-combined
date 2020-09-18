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
  version = "0.5.0";

  # TODO: remove when 20.09 released, needed to build on CI.
  cargoSha256 = if
    lib.versionOlder lib.trivial.release "20.09"
    then "0ymb1w74j6bss9sgn5nmm63lj0p1j6zwhdp4f81c7fd3l80jg036"
    else "12ab7z4mbn71ffqkifkbphg0ga9j8zic5pz9160z7xf1xvd6831d";
  legacyCargoFetcher = true;  # TODO: Remove on next nixos release. Cargo SHA mismatch b/w unstable & release.

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "retworkx";
    rev = version;
    sha256 = "0gk3cl3vpmkhngi1s1ki5akvqqixd926c902s7x8w73hc5lwdwq7";
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
