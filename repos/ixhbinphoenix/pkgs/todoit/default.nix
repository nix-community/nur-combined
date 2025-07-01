{ pkgs, lib, fetchFromGitea }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "todoit";
  version = "0.1.5";

  src = fetchFromGitea {
    domain = "git.ixhby.dev";
    owner = "ixhbinphoenix";
    repo = "todoit";
    rev = version;
    hash = "sha256-4CkCSahOQFFBwiHY2x6YyKgBvZCziXNNQAVMe/sk5u0=";
  };

  cargoHash = "sha256-0Gm7pwhTTfVp4WVCbxFZDpWEk+sbRWMXUB+g7v6wQ3A=";

  meta = with lib; {
    description = "CLI Tool for showing all TODO's in a project";
    homepage = "https://git.ixhby.dev/ixhbinphoenix/todoit";
    license = licenses.gpl3Only;
  };
}
