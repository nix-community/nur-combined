{ lib, stdenv
, darwin

, fetchFromGitHub

, rustPlatform
}:
rustPlatform.buildRustPackage rec {
  pname = "wit-deps";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "bytecodealliance";
    repo = "wit-deps";
    rev = "v${version}";
    hash = "sha256-urAGMGMH5ousEeVTZ5AaLPfowXaYQoISNXiutV00iQo=";
  };

  cargoHash = "sha256-p8ffC9gGI68tPgNdjGRVtxlVZgVHQ3dixexi1UPiZZM=";

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  doCheck = false;

  meta = with lib; {
    description = "WIT dependency manager";
    homepage = "https://github.com/bytecodealliance/wit-deps";
    changelog = "https://github.com/bytecodealliance/wit-deps/blob/${src.rev}/CHANGELOG.md";
    license = licenses.asl20-llvm;
    mainProgram = "wit-deps";
  };
}
