{ fetchFromGitHub }:

rec {
  version = "3.24.1";
  src = fetchFromGitHub {
    owner = "DeterminateSystems";
    repo = "nix-src";
    tag = "v${version}";
    hash = "sha256-pDSWr7TQd9V9thIxlsqHzVGkuymDkckQpgaXLf7EuJ0=";
  };
}
