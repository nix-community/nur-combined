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
  version = "0.9.0";
  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "retworkx";
    rev = version;
    sha256 = "0adb9zar8wihjkywal13b6w21hf5z9fh168wnc7j045y2ixw6vnm";
  };
  cargoSha256 = "09zmp4zf3r3b7ffgasshr21db7blkwn7wkibka9cbh61593845dh";
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
