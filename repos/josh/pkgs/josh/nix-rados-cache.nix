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
  version = "0-unstable-2026-09-12";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "nix-rados-cache";
    rev = "006f84f69808936cad53f87576ba45bfdae6ae07";
    hash = "sha256-feHMoZcveV70pJBB2sQEz080/qnV66uVJvM0oRFuEoc=";
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
