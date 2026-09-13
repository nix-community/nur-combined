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
  version = "0-unstable-2026-09-13";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "nix-rados-cache";
    rev = "d6d746c5e61974a79cc4dd00846237e05a6e2730";
    hash = "sha256-KFdL6yq8Nvpq1MLGyxM8szZS377JNepnjp98+n2k+Vs=";
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
