{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ceph,
  go,
  nix-update-script,
}:
buildGoModule {
  pname = "nix-rados-cache";
  version = "0-unstable-2026-09-15";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "nix-rados-cache";
    rev = "cd40530a716c960065303d9f8d8f99c5b49673ee";
    hash = "sha256-N1vh/452j7MBgrIlKFPSpNLmzUfBDGfWnMrPXkfeXxY=";
  };

  vendorHash = "sha256-r4QLLz3UBOttXhu3dO6wEyeckxUiBx7RKfPlw4LrCjw=";

  buildInputs = [
    ceph
  ];

  env.CGO_ENABLED = 1;

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Nix HTTP binary cache backed by Ceph RADOS via librados";
    homepage = "https://github.com/josh/nix-rados-cache";
    license = lib.licenses.mit;
    mainProgram = "nix-rados-cache";
    inherit (ceph.meta) platforms;
    broken = lib.strings.versionOlder go.version "1.26.7";
  };
}
