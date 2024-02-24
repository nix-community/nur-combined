{ lib, stdenv, rustPlatform, fetchFromGitHub, SystemConfiguration }:

rustPlatform.buildRustPackage rec {
  pname = "ttb";
  version = "0-unstable-2022-12-14";

  src = fetchFromGitHub {
    owner = "TheOpenDictionary";
    repo = "ttb";
    rev = "535e99f3607ef9b03a2e9b7ef05ab9a78448ef1a";
    hash = "sha256-D5XOqbgpLkUKFOJe9kArARTMd3sM2rOFwJTtwKe6Ypk=";
  };

  cargoHash = "sha256-IVbF+6ibTTb+LML5gZyB0DIWsxpSE3dDsCtoejdR/qw=";

  cargoPatches = [ ./cargo-lock.patch ];

  buildInputs = lib.optional stdenv.isDarwin SystemConfiguration;

  meta = with lib; {
    description = "A lightning-fast tool for querying Tatoebe from the command-line";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    broken = true;
  };
}
