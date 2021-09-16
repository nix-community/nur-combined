{ lib
, stdenv
, buildPythonPackage
, rustPlatform
, python
, fetchFromGitHub
, pipInstallHook
, maturin
, pip
, libiconv
  # Check inputs
, pytestCheckHook
, fixtures
, graphviz
, matplotlib
, networkx
, numpy
, pydot
}:

let
  pname = "retworkx";
  version = "0.10.2";
  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "retworkx";
    rev = version;
    sha256 = "sha256-F2hcVUsuHcNfsg3rXYt/erc0zB6W7GdepVOReP3u4lg=";
  };
  cargoSha256 = "1ajzxwx0rrzzq844sbv986h4yg6krzhfagc0q6px3sbhnkm9s2i3";
  buildInputs = lib.optionals stdenv.isDarwin [ libiconv ];
  installCheckInputs = [
    pytestCheckHook
    fixtures
    graphviz
    matplotlib
    numpy
    networkx
    pydot
  ];
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
    broken = versionOlder lib.version "21.05";  # TODO: enable build on 20.09. Broken due to cargo resolving on older cargo version, might work with a Cargo.toml patch?
  };

  pre2105Package = rustPlatform.buildRustPackage rec {
    inherit pname version src cargoSha256 buildInputs installCheckInputs preCheck postCheck meta;

    legacyCargoFetcher = true;  # TODO: Remove on next nixos release. Cargo SHA mismatch b/w unstable & release.

    propagatedBuildInputs = [ python ];

    nativeBuildInputs = [ pipInstallHook maturin pip ];

    # Needed b/c need to check AFTER python wheel is installed (using Rust Build, not buildPythonPackage)
    doCheck = false;
    doInstallCheck = true;

    buildPhase = ''
      runHook preBuild
      maturin build --release --manylinux off --strip
      runHook postBuild
    '';

    installPhase = ''
      install -Dm644 -t dist target/wheels/*.whl
      pipInstallPhase
    '';
  };

  nixpkgs2105Package = buildPythonPackage {
    inherit pname version src buildInputs preCheck postCheck meta ;
    format = "pyproject";

    cargoDeps = rustPlatform.fetchCargoTarball {
      inherit src;
      name = "${pname}-${version}";
      sha256 = cargoSha256;
    };

    nativeBuildInputs = with rustPlatform; [ cargoSetupHook maturinBuildHook ];

    pythonImportsCheck = [ "retworkx" ];
    checkInputs = installCheckInputs;
  };
in
  (if lib.versionAtLeast lib.trivial.release "21.05" then nixpkgs2105Package else pre2105Package)
