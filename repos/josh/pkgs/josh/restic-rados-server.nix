{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ceph,
  go,
  nix-update-script,
  runCommand,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "restic-rados-server";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "restic-rados-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bnfCEhrYBaBt6kNNLlxKL6H8EvunICbpbPtgtsXVfQs=";
  };

  vendorHash = "sha256-k+/WFrjZmFwG+ufYfwXjmHqE133OHPNfPnJM/NZ/kok=";

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

    help =
      runCommand "test-restic-rados-server-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
        ''
          restic-rados-server --help
          touch $out
        '';
  };

  meta = {
    description = "Restic repository backend that stores data in raw Ceph RADOS";
    homepage = "https://github.com/josh/restic-rados-server";
    license = lib.licenses.mit;
    mainProgram = "restic-rados-server";
    inherit (ceph.meta) platforms;
    broken = lib.strings.versionOlder go.version "1.26.5";
  };
})
