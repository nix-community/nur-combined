{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wonnx";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "webonnx";
    repo = "wonnx";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1h9Sif7eDTouwFssEN8bPxFLGMakXLm0nM75tN2nnJ4=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  # no GPU found during test
  doCheck = false;

  cargoHash = "sha256-Ib8JYu4+64THsK0Wxb9gPkvBh1xiKaYZraJRKKzpNTs=";

  meta = {
    description = "GPU-accelerated ONNX inference run-time written 100% in Rust, ready for the web";
    homepage = "https://github.com/webonnx/wonnx";
    license = with lib.licenses; [ mit ];
  };
})
