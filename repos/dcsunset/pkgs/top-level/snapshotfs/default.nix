{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "snapshotfs";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-T9H+VABfDmqM9TG+M/ou63p6Tht9wnDYiQkC/87KiqM=";
  };

  cargoHash = "sha256-pDz1csiJ20iJ6rkVpFIfy2HQpWxC6iELdoYE6ws7ZLI=";

  meta = with lib; {
    description = "A fuse-based read-only filesystem to provide a snapshot view (tar archives) of directories or files without actually creating the archives";
    homepage = "https://github.com/DCsunset/snapshotfs";
    license = licenses.agpl3;
  };
}
