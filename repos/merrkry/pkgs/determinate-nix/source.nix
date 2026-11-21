{ fetchFromGitHub }:

rec {
  version = "3.24.3";
  src = fetchFromGitHub {
    owner = "DeterminateSystems";
    repo = "nix-src";
    tag = "v${version}";
    hash = "sha256-mZiNGyjdUVlfEvllLQKVK0ZbkxWIAC42jjERazi+lfU=";
  };
}
