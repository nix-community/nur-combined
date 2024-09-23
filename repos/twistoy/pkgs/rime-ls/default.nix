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
  version = "v0.4.0";

  src = fetchFromGitHub {
    owner = "wlh320";
    repo = "rime-ls";
    rev = "v0.4.0";
    sha256 = "sha256-ZqoRFIF3ehfEeTN+ZU+/PAzA4JyS1403+sqZdzwJHA8=";
  };

  nativeBuildInputs = [
    librime
    rustPlatform.bindgenHook
  ];

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "librime-sys-0.1.0" = "sha256-zJShR0uaKH42RYjTfrBFLM19Jaz2r/4rNn9QIumwTfA=";
    };
  };

  cargoHash = lib.fakeHash;

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
