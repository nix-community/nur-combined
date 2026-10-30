{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ceph,
  nix-update-script,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "restic-rados-server";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "restic-rados-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-anM7V/Tw2iuOB3nNjGLiYmmo9nbuL04LQ/5hWNQZRv8=";
  };

  vendorHash = "sha256-IDw0PpUhNNSHKVxYLF3y3wUw+uE9bM3LVmOzNPKtfwE=";

  buildInputs = [
    ceph
  ];

  env.CGO_ENABLED = 1;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };

  };

  meta = {
    description = "Restic repository backend that stores data in raw Ceph RADOS";
    homepage = "https://github.com/josh/restic-rados-server";
    license = lib.licenses.mit;
    mainProgram = "restic-rados-server";
    inherit (ceph.meta) platforms;
  };
})
