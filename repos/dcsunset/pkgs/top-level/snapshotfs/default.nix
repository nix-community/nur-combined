{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "snapshotfs";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-wa9vyKaEbjV2xTygCeqHtpCINqor6owdMW0sRqUpJwM=";
  };

  cargoHash = "sha256-OSSHOkb4RVy1TiuehmY33y7qVlSrYFSpOoSOmjgWCtw=";

  meta = with lib; {
    description = "A fuse-based read-only filesystem to provide a snapshot view (tar archives) of directories or files without actually creating the archives";
    homepage = "https://github.com/DCsunset/snapshotfs";
    license = licenses.agpl3Only;
  };
}
