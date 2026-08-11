{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lingua-rs";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "pemistahl";
    repo = "lingua-rs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oDzmNjjVj/PiV9DHsjKC4uMtDeW8KLawj/5eK5l80ZE=";
  };

  cargoHash = "sha256-DazKsJ6j62NZSMRLhNLi0LpWrTGapXOQ/ebbF7MCj7Y=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    zstd
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
