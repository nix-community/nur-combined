{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  cargo,
  rustPlatform,
  rustc,
  # abi3audit,
  maturin,
  pip,
  pre-commit,
  pytest,
  pytest-codspeed,
  # pytest-github-actions-annotate-failures,
}:

buildPythonPackage rec {
  pname = "bencode-rs";
  version = "0.0.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "trim21";
    repo = "bencode-rs";
    rev = "v${version}";
    hash = "sha256-DJJ1aCmKPcnFLL//C5hMq0zQOpHLNC17SorM4Q5yqd0=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-rAO9EhQmAfSLZzqpewR5bkck/vVcT1CkQofo6QPCkWk=";
  };

  build-system = [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  dependencies = [
    # abi3audit
    maturin
    pip
    pre-commit
    pytest
    pytest-codspeed
    # pytest-github-actions-annotate-failures
  ];

  pythonImportsCheck = [
    "bencode_rs"
  ];

  meta = {
    description = "";
    homepage = "https://github.com/trim21/bencode-rs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
