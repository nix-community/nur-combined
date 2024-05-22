{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  Security,
}:

rustPlatform.buildRustPackage rec {
  pname = "hecate";
  version = "0.87.0";

  src = fetchFromGitHub {
    owner = "Hecate";
    repo = "Hecate";
    rev = "v${version}";
    hash = "sha256-X+49Mnls5xK6ag1QcvEm0GvLPmvcRBwNn/1vnC9GJO8=";
  };

  cargoHash = "sha256-ROx90hWk9q5E/Yfy9luHbB1XyyLqw2KEl92niBNapBI=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ] ++ lib.optional stdenv.isDarwin Security;

  doCheck = false;

  meta = with lib; {
    description = "Fast Geospatial Feature Storage API";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    broken = true;
  };
}
