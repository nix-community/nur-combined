{ fetchFromGitHub }:

rec {
  version = "3.23.2";
  src = fetchFromGitHub {
    owner = "DeterminateSystems";
    repo = "nix-src";
    tag = "v${version}";
    hash = "sha256-Ir2Kf9gGrXqh48My/k5xMzKbWS9JSthDPjdBOmhnzrE=";
  };
}
