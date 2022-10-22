{ lib, stdenv, rustPlatform, fetchFromGitHub, pkg-config, openssl, Security }:

rustPlatform.buildRustPackage rec {
  pname = "hecate";
  version = "0.82.2";

  src = fetchFromGitHub {
    owner = "Mapbox";
    repo = "Hecate";
    rev = "v${version}";
    hash = "sha256-ffDBcrrg7iC8XkA1HO+qiRzZfNS6bF4mEXXqdM8w3uA=";
  };

  cargoHash = "sha256-OwKQiDRgYVSIIDnmjWyXSvFc3/L/dgcOjuXf/lE4N68=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ] ++ lib.optional stdenv.isDarwin Security;

  doCheck = false;

  meta = with lib; {
    description = "Fast Geospatial Feature Storage API";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
