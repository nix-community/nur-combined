{ lib, stdenv
, darwin

, fetchFromGitHub

, rustPlatform
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

  cargoHash = "sha256-LkJv/v2M5FbYbk+PqVEE+MTa4KNZ1kguR3DkDHpU3Bg=";

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
