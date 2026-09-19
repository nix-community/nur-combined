{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ceph,
  nix-update-script,
}:
buildGoModule {
  pname = "nix-rados-cache";
  version = "0-unstable-2026-09-19";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "nix-rados-cache";
    rev = "f5817c6864bb6a6a8bfe9e1aba8f5dd0617b3fc8";
    hash = "sha256-rlIDddUJyn92A/dbnQyiF+2Pu7fWWNNSewMjPTdTAO0=";
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
  };
}
