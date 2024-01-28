{ lib, stdenv, rustPlatform, fetchFromGitHub, libiconv, Foundation }:

rustPlatform.buildRustPackage rec {
  pname = "xtr";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "woboq";
    repo = "tr";
    rev = "v${version}";
    hash = "sha256-Un7p8n0+rSyDzEaUGuFXXWUDShR6AZgIYza40ahdZU8=";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-1OII7TCmnlXO1pkY9MQe+Ig+UIUIE3aVIDU9PL4PW0Q=";

  buildInputs = lib.optionals stdenv.isDarwin [ libiconv Foundation ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-incompatible-function-pointer-types";

  hardeningDisable = lib.optional stdenv.isDarwin "format";

  meta = with lib; {
    description = "Translation tools for rust";
    inherit (src.meta) homepage;
    license = with licenses; [ agpl3 mit ];
    maintainers = [ maintainers.sikmir ];
  };
}
