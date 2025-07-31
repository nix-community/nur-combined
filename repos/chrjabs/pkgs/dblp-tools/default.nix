{
  lib,
  rustPlatform,
  openssl,
  pkg-config,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "dblp-tools";
  version = "0.1.0-unstable";

  src = fetchFromGitHub {
    owner = "chrjabs";
    repo = "dblp-helper";
    rev = "818ae3aadf5cf8265b304cde9098778889fced7e";
    hash = "sha256-1kvckjqQvIXH6ZZ4FQoM9ap601dHdLt7W9vQShlZgaQ=";
  };

  cargoHash = "sha256-YG62PRunDg3Vzvqoa5Ul/7rOTYphukVVSGFAwowvFTg=";

  useNextest = true;

  buildInputs = [ openssl ];
  nativeBuildInputs = [ pkg-config ];

  meta = with lib; {
    description = "helper tool for working with DBLP bibliographies";
    homepage = "https://github.com/chrjabs/dblp-helper";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ (import ../../maintainer.nix { inherit (lib) maintainers; }) ];
    mainProgram = "dblp";
  };
}
