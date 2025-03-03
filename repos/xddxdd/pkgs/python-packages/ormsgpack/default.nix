{
  lib,
  sources,
  buildPythonPackage,
  rustPlatform,
}:
buildPythonPackage rec {
  inherit (sources.ormsgpack) pname version src;
  pyproject = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-tReppq5Gzp5k9wdLbEd/IGHjpbhmWWw3EqN8vCPNTRw=";
  };

  # Enable nightly features for Rust compiler
  RUSTC_BOOTSTRAP = 1;

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  pythonImportsCheck = [ "ormsgpack" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Msgpack serialization/deserialization library for Python, written in Rust using PyO3 and rust-msgpack";
    homepage = "https://github.com/aviramha/ormsgpack";
    license = with lib.licenses; [
      asl20
      mit
    ];
  };
}
