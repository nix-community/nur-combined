{ lib, fetchFromGitHub, rustPlatform, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "wonnx";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "webonnx";
    repo = "wonnx";
    rev = "v${version}";
    hash = "sha256-m+97yOCEgNZqS9MLB55ZuGj0jUDSYivYTjPgz6ENH+M=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  # no GPU found during test
  doCheck = false;

  cargoHash = "sha256-4y9c6upHfUjotypJJhKFD9sKpOdSGkGet2uR+nE8x7o=";

  meta = with lib; {
    description =
      "GPU-accelerated ONNX inference run-time written 100% in Rust, ready for the web";
    inherit (src.meta) homepage;
    license = with licenses; [ mit ];
  };
}
