{ fetchFromGitHub }:

rec {
  version = "3.24.2";
  src = fetchFromGitHub {
    owner = "DeterminateSystems";
    repo = "nix-src";
    tag = "v${version}";
    hash = "sha256-QY69Nw0WhXSvT2n2ldI5gt0h4ofbAVoi7EYGJGyNLl0=";
  };
}
