{ fetchFromGitHub }:

rec {
  version = "0.22.0";
  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "delta-nix";
    tag = "v${version}";
    hash = "sha256-n8zInXuH9eA0awSGp8cUfUKZ2zUyKw2BJleUSUToC8k=";
  };
}
