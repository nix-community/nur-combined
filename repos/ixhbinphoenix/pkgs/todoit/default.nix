{ pkgs, lib, fetchFromGitea }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "todoit";
  version = "0.1.0";

  src = fetchFromGitea {
    domain = "git.ixhby.dev";
    owner = "ixhbinphoenix";
    repo = "todoit";
    rev = version;
    hash = "sha256-IGXop8Ei/uTtWMjS/dmV4fr7qcJvCy5PQFjfDf/u0Dc=";
  };

  cargoHash = "sha256-IrO3yku6uxk5OnWBDRZJ/9chCXWqsQQtLSUyof9Lzp4=";

  meta = with lib; {
    description = "CLI Tool for showing all TODO's in a project";
    homepage = "https://git.ixhby.dev/ixhbinphoenix/todoit";
    license = licenses.gpl3Only;
  };
}
