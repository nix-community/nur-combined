{ lib, stdenv, rustPlatform, fetchFromGitHub, libiconv, Foundation }:

rustPlatform.buildRustPackage rec {
  pname = "xtr";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "woboq";
    repo = "tr";
    rev = "v${version}";
    hash = "sha256-IgiCcZHtcNOGw0l/sYb4nz15hhzmZ+4G6zzO3I4hpxA=";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-6a+n1ApCyfcPQy4wqWNDhXCRGCbJ8BgxHxz/b9uY6Qk=";

  buildInputs = lib.optionals stdenv.isDarwin [ libiconv Foundation ];

  hardeningDisable = lib.optional stdenv.isDarwin "format";

  meta = with lib; {
    description = "Translation tools for rust";
    inherit (src.meta) homepage;
    license = with licenses; [ agpl3 mit ];
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
