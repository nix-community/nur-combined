{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "dtn7-rs";
  version = "0.17.3";

  src = fetchFromGitHub {
    owner = "dtn7";
    repo = "dtn7-rs";
    rev = "v${version}";
    sha256 = "sha256-ML+/sUn9/cFH8CySQIwnFthGjFnTy549MrXNolSL5LY=";
  };

  cargoSha256 = "sha256-ZkO2853fPLTyqdJzIBHB+upBz5bZBsN9dhiQ6cJPiDQ=";

  meta = with lib; {
    description = "Rust implementation of a DTN based on RFC9171";
    homepage = "https://github.com/dtn7/dtn7-rs";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ oxzi ];
  };
}
