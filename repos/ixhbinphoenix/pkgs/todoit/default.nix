{ pkgs, lib, fetchFromGitea }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "todoit";
  version = "0.1.1";

  src = fetchFromGitea {
    domain = "git.ixhby.dev";
    owner = "ixhbinphoenix";
    repo = "todoit";
    rev = version;
    hash = "sha256-IGXop8Ei/uTtWMjS/dmV4fr7qcJvCy5PQFjfDf/u0Dc=";
  };

  cargoHash = "sha256-6lH5KlfA4meAkyLd9bRUKfhllV10PK0fsS3M609xeT0=";

  meta = with lib; {
    description = "CLI Tool for showing all TODO's in a project";
    homepage = "https://git.ixhby.dev/ixhbinphoenix/todoit";
    license = licenses.gpl3Only;
  };
}
