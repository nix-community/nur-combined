{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
  librime,
}:
rustPlatform.buildRustPackage {
  pname = "rime-ls";
  version = "2024-02-29";

  src = fetchFromGitHub {
    owner = "TwIStOy";
    repo = "rime-ls";
    rev = "2d6e765e268b789ab02d177556f701db1711b16a";
    sha256 = "sha256-Q1o/a1M8dy5mZDiWOVVhNl5rYzLsrRdL9dXfsLgcu1I=";
  };

  nativeBuildInputs = [
    librime
    rustPlatform.bindgenHook
  ];

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "librime-sys-0.1.0" = "sha256-Q8JrPksXUhTNC4qCJgezYyC/WSZ0EP8aGs0duwwT7/k=";
    };
  };

  postPatch = ''
    # update Cargo.lock to fix build
    ln -sf ${./Cargo.lock} Cargo.lock
  '';

  C_INCLUDE_PATH = "${librime}/include";
  LIBRARY_PATH = "${librime}/lib";

  buildInputs =
    [
      librime
    ]
    ++ lib.optional stdenv.isDarwin [darwin.apple_sdk.frameworks.Security];

  doCheck = false;

  meta = with lib; {
    description = "A language server for Rime input method engine";
    homepage = "https://github.com/wlh320/rime-ls";
    license = licenses.bsd3;
  };
}
