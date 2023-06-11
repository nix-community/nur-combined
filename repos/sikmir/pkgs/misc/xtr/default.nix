{ lib, stdenv, rustPlatform, fetchFromGitHub, libiconv, Foundation }:

rustPlatform.buildRustPackage rec {
  pname = "xtr";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "woboq";
    repo = "tr";
    rev = "v${version}";
    hash = "sha256-8Ncoo5Nzm4dj2A0L02o8OoT3ZXRciDnwCbHfLIggPw4=";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-g/8OZmMa2gzRr2ft6/0Tur23sjB+SEQq3/qiiAD5y6M=";

  buildInputs = lib.optionals stdenv.isDarwin [ libiconv Foundation ];

  hardeningDisable = lib.optional stdenv.isDarwin "format";

  meta = with lib; {
    description = "Translation tools for rust";
    inherit (src.meta) homepage;
    license = with licenses; [ agpl3 mit ];
    maintainers = [ maintainers.sikmir ];
  };
}
