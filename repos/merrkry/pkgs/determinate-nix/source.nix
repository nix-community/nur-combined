{ fetchFromGitHub }:

rec {
  version = "3.23.3";
  src = fetchFromGitHub {
    owner = "DeterminateSystems";
    repo = "nix-src";
    tag = "v${version}";
    hash = "sha256-+wZuesAaCfqohENc3UCsKiNbdarDZp+8oyiLRPUfdj4=";
  };
}
