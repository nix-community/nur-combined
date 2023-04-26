{ lib, fetchFromGitHub, rustPlatform, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "wonnx";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "webonnx";
    repo = "wonnx";
    rev = "v${version}";
    hash = "sha256-BarEptmAK7JR45Zc3OswTvkqrXjcshuB9L8DldBtmXQ=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  # no GPU found during test
  doCheck = false;

  cargoHash = "sha256-784F2SQbXfnv+311uZvbI6VRfpoiSsRtwDNWRqe/vIA=";

  meta = with lib; {
    description =
      "GPU-accelerated ONNX inference run-time written 100% in Rust, ready for the web";
    inherit (src.meta) homepage;
    license = with licenses; [ mit ];
  };
}
