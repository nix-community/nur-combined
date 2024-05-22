{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  libiconv,
  Foundation,
}:

rustPlatform.buildRustPackage rec {
  pname = "xtr";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "woboq";
    repo = "tr";
    rev = "v${version}";
    hash = "sha256-Un7p8n0+rSyDzEaUGuFXXWUDShR6AZgIYza40ahdZU8=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  buildInputs = lib.optionals stdenv.isDarwin [
    libiconv
    Foundation
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-incompatible-function-pointer-types";

  hardeningDisable = lib.optional stdenv.isDarwin "format";

  meta = with lib; {
    description = "Translation tools for rust";
    inherit (src.meta) homepage;
    license = with licenses; [
      agpl3Only
      mit
    ];
    maintainers = [ maintainers.sikmir ];
    mainProgram = "xtr";
  };
}
