{ lib, fetchFromGitHub, rustPlatform, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "wonnx";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "webonnx";
    repo = "wonnx";
    rev = "v${version}";
    hash = "sha256-yQ8JTSDT63BP5IXHTOtbgsy6YR+iDRehmSy+XfBxxn8=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  # no GPU found during test
  doCheck = false;

  cargoHash = "sha256-5XBvCm5u7c00GYoC+BgWJFw6XpukyPYrJa64blRofjY=";

  meta = with lib; {
    description =
      "A GPU-accelerated ONNX inference run-time written 100% in Rust, ready for the web";
    inherit (src.meta) homepage;
    license = with licenses; [ mit ];
  };
}
