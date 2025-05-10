{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  libiconv,
}:

rustPlatform.buildRustPackage rec {
  pname = "xtr";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "woboq";
    repo = "tr";
    tag = "v${version}";
    hash = "sha256-Un7p8n0+rSyDzEaUGuFXXWUDShR6AZgIYza40ahdZU8=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-incompatible-function-pointer-types";

  hardeningDisable = lib.optional stdenv.isDarwin "format";

  meta = {
    description = "Translation tools for rust";
    homepage = "https://github.com/woboq/tr";
    license = with lib.licenses; [
      agpl3Only
      mit
    ];
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "xtr";
  };
}
