{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  darwin,
  buildPackages,
}:

rustPlatform.buildRustPackage rec {
  pname = "bbox";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "bbox-services";
    repo = "bbox";
    rev = "v${version}";
    hash = "sha256-Vhzch4jnWtYQ2/x9tNGph8FDDxB1vRR9L9KVZf3Tha4=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "tile-grid-0.5.2" = "sha256-usU44667dCob0J+RGn2nGMfdUSlRuVGM4bTfm19hD9E=";
    };
  };

  PROTOC = "${buildPackages.protobuf}/bin/protoc";

  buildInputs = lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.SystemConfiguration;

  cargoBuildFlags = [
    "--package"
    "bbox-server"
    "--package"
    "bbox-tile-server"
  ];

  meta = with lib; {
    description = "BBOX services";
    inherit (src.meta) homepage;
    license = with licenses; [
      asl20
      mit
    ];
    maintainers = [ maintainers.sikmir ];
  };
}
