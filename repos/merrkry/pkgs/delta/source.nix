{ fetchFromGitHub }:

rec {
  version = "0.19.2";
  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "delta-nix";
    tag = "v${version}";
    hash = "sha256-QLomEmH5+1flz42ONMI8yFc4fNuKITGRj0RSkxPsxyE=";
  };
}
