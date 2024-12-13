{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  rustPlatform,
  # Deps
}:
buildPythonPackage rec {
  pname = "arro3-core";
  version = "0.4.4";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "kylebarron";
    repo = "arro3";
    rev = "py-v${version}";
    hash = "sha256-NUSl5xzYc1qNOQQot2UfaL/r1ky/2qG74LC54K2ND2E=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "pyo3-object_store-0.1.0-beta.1" = "sha256-39IeTTFY4rJQqJe8ISZ10DwZKz6SgCxtrLBfb47LSkM=";
    };
  };

  buildAndTestSubdir = "arro3-core";

  # buildInputs = [ protobuf ];
  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  # propagatedBuildInputs = [
  #   narwhals
  #   arro3-core
  # ];
  #
  pythonImportsCheck = ["arro3.core._core"];

  meta = with lib; {
    description = "A minimal Python library for Apache Arrow, binding to the Rust Arrow implementation";
    homepage = "https://github.com/kylebarron/arro3";
    license = with licenses; [
      asl20
      mit
    ];
    maintainers = with maintainers; [renesat];
  };
}
