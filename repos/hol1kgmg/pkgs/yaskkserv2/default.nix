{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
}:

rustPlatform.buildRustPackage {
  pname = "yaskkserv2";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "wachikun";
    repo = "yaskkserv2";
    rev = "0.1.7";
    hash = "sha256-bF8OHP6nvGhxXNvvnVCuOVFarK/n7WhGRktRN4X5ZjE=";
  };

  cargoHash = "sha256-cycs8Zism228rjMaBpNYa4K1Ll760UhLKkoTX6VJRU0=";

  buildInputs = [ openssl ];
  nativeBuildInputs = [ pkg-config ];

  doCheck = false;

  meta = {
    description = "Yet Another Skkserv 2";
    homepage = "https://github.com/wachikun/yaskkserv2";
    license = [
      lib.licenses.mit
      lib.licenses.asl20
    ];
    mainProgram = "yaskkserv2";
  };
}
