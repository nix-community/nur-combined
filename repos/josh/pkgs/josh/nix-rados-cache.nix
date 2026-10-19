{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ceph,
  nix-update-script,
}:
buildGoModule {
  pname = "nix-rados-cache";
  version = "0-unstable-2026-10-19";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "nix-rados-cache";
    rev = "469c89139ed93f5725b4e04755470d95451088aa";
    hash = "sha256-/VxBwKYjWTUPL5/RLdm4QUNyuPyshIz6KORNHP6Hdwo=";
  };

  vendorHash = "sha256-9ECa9ji0VZb2/8YVaZxpNgnDUP6/ZajCof5BmIKPPbA=";

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
