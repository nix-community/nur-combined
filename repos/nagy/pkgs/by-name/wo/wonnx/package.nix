{ lib, fetchFromGitHub, rustPlatform, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "wonnx";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "webonnx";
    repo = "wonnx";
    rev = "v${version}";
    hash = "sha256-1h9Sif7eDTouwFssEN8bPxFLGMakXLm0nM75tN2nnJ4=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  # no GPU found during test
  doCheck = false;

  cargoHash = "sha256-c7C10kw9i0hycLhwbAZaBeh2HpJVo0a4S2g7S+r/UeE=";

  meta = with lib; {
    description =
      "GPU-accelerated ONNX inference run-time written 100% in Rust, ready for the web";
    inherit (src.meta) homepage;
    license = with licenses; [ mit ];
  };
}
