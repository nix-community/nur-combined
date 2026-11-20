{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ceph,
  nix-update-script,
}:
buildGoModule {
  pname = "nix-rados-cache";
  version = "0-unstable-2026-11-19";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "nix-rados-cache";
    rev = "a34a7ccda0d5ccfb78ed761611e2d672430240bc";
    hash = "sha256-CjP+VhMoLjs+hsyYh2byW30iA8sgRLLz4EtH7J9K4Ac=";
  };

  vendorHash = "sha256-IZTouOW33N3vtoP8FuszBEk/t9XhPUpuRa7Sn5JOQcg=";

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
