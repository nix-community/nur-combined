{
  lib,
  stdenv,
  darwin,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "wit-deps";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "bytecodealliance";
    repo = "wit-deps";
    rev = "v${version}";
    hash = "sha256-tbHAvdDN2qkJRRfy9L3apBULRVttb7Jh00bDlb1OKJ4=";
  };

  cargoHash = "sha256-54TK9ZeRZ7PPA/8DQ6sH60LLIdgSG+hV+HI0zg1IxJI=";

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  doCheck = false;

  meta = with lib; {
    description = "WIT dependency manager";
    homepage = "https://github.com/bytecodealliance/wit-deps";
    changelog = "https://github.com/bytecodealliance/wit-deps/blob/${src.rev}/CHANGELOG.md";
    licenses = if licenses ? asl20-llvm
      then [ licenses.asl20-llvm ]
      else [ licenses.asl20 licenses.llvm-exception ];
    mainProgram = "wit-deps";
  };
}
