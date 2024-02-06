{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
  librime,
}:
rustPlatform.buildRustPackage rec {
  pname = "rime-ls";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "wlh320";
    repo = "rime-ls";
    rev = "v${version}";
    sha256 = "sha256-6jiyOVjnYpX9C9H2+tTJqRUeqNWNVJ+acqStwMkaWb0=";
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
