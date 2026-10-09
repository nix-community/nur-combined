{ fetchFromGitHub }:

rec {
  version = "0.19.1";
  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "delta-nix";
    tag = "v${version}";
    hash = "sha256-eLNULrR3uU1lt7UEVgd3FDrgMvw5WkeTIL2D6QQRs5o=";
  };
}
