{ pkgs, lib, fetchFromGitea }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "todoit";
  version = "0.1.3";

  src = fetchFromGitea {
    domain = "git.ixhby.dev";
    owner = "ixhbinphoenix";
    repo = "todoit";
    rev = version;
    hash = "sha256-RNcZdNCIcAR1JCEnS3XjOs8xfvA2xLSZSHxvIQX0itE=";
  };

  cargoHash = "sha256-gp9GKOKWW+kZTBu+wns/d8tYG1FjHzh1xeBdcQ6eSBQ=";

  meta = with lib; {
    description = "CLI Tool for showing all TODO's in a project";
    homepage = "https://git.ixhby.dev/ixhbinphoenix/todoit";
    license = licenses.gpl3Only;
  };
}
