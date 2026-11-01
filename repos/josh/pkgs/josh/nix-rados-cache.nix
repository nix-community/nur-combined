{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ceph,
  nix-update-script,
}:
buildGoModule {
  pname = "nix-rados-cache";
  version = "0-unstable-2026-10-31";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "nix-rados-cache";
    rev = "ef5bcc8aab690674840d5ad16701727566b47f58";
    hash = "sha256-TlpwNPHytouI6+XP7qvTOLz6JrmqNpaqVNFonhn3dTI=";
  };

  vendorHash = "sha256-eslkE1Wm8wbJUO/lp0RxocTjj/KbM4xLqrZZI8p28RQ=";

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
