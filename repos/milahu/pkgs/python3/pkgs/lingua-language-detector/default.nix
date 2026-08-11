{
  lib,
  python3,
  fetchFromGitHub,
  cargo,
  pkg-config,
  rustPlatform,
  rustc,
  zstd,
  python,
  # TODO? link dynamically to ${lingua-rs}/lib/liblingua.so
  # or somehow merge lingua-rs and python3.pkgs.lingua-language-detector
  # lingua-rs,
}:

python3.pkgs.buildPythonPackage (finalAttrs: {
  pname = "lingua-language-detector";
  # NOTE version mismatch
  # https://github.com/pemistahl/lingua-py - 2.2.0
  # https://github.com/pemistahl/lingua-rs - 1.8.0
  version = "2.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pemistahl";
    repo = "lingua-rs";
    # tag = "v${finalAttrs.version}";
    # https://github.com/pemistahl/lingua-rs/pull/565
    rev = "69ca1331ef9abd7ddbf2bbf6b1dd7fcbf97b33e4";
    hash = "sha256-ftioVqwqfsq9OVK7O4LKkwv/svLMGuG4zynS62RwJPY=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-9YHXL054Ek4b/MPoX4TMbnF7Dn/uuTLWdHKqh8wI4Wo=";
  };

  build-system = [
    cargo
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  buildInputs = [
    zstd
  ];

  optional-dependencies = with python3.pkgs; {
    test = [
      pytest
    ];
  };

  pythonImportsCheck = [
    "lingua"
  ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  meta = {
    description = "The most accurate natural language detection library for Rust, suitable for short text and mixed-language text";
    homepage = "https://github.com/pemistahl/lingua-rs";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
})
