{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, curl
, libgit2
, openssl
, zlib
, stdenv
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "cargo2nix";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "cargo2nix";
    repo = "cargo2nix";
    rev = "v${version}";
    hash = "sha256-b7ToXDqgTXsAWPluHEiFmiqaJwIrdSyJgyAOBfty5xo=";
  };

  cargoHash = "sha256-v352Jyyd/Hd3FXqf3bgGOh3Hfz37c1PIaJzHjsVXYsc=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    curl
    libgit2
    openssl
    zlib
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.Security
  ];

  meta = with lib; {
    description = "Granular caching, development shell, Nix & Rust integration";
    homepage = "https://github.com/cargo2nix/cargo2nix";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
