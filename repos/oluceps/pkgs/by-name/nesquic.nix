{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage {
  pname = "nesquic";
  version = "unstable-2024-04-21";

  src = fetchFromGitHub {
    owner = "gmelodie";
    repo = "nesquic";
    rev = "163149b829b2fc4f7d8dc1c00a1f14385c7eafdb";
    hash = "sha256-qKYNj4HYTNqFFw1f8L81uLjW35jyQf+OKKghQ1KtY4A=";
  };

  cargoHash = "sha256-xx/deLo7EGO8BJv5jEYHCkIJarDXYNqA+LyIpSlz7pA=";

  buildInputs = lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ];

  meta = with lib; {
    description = "A Rust Netcat for QUIC";
    homepage = "https://github.com/gmelodie/nesquic";
    license = licenses.mit;
    maintainers = with maintainers; [ oluceps ];
    mainProgram = "nesquic";
  };
}
