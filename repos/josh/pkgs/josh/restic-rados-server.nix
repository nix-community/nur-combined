{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
  testers,
  ceph,
  restic,
}:
buildGoModule (finalAttrs: {
  pname = "restic-rados-server";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "restic-rados-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LyUA5nAYylgfbUzxEvo//jIk7MxE2nk20mQS1rGONKY=";
  };

  vendorHash = "sha256-wivLXMYNzChTvy1r/XmIkxZxYLVVJLdyhSS4C+SYjFg=";

  env.CGO_ENABLED = 1;

  ldflags = [
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  buildInputs = [
    ceph
  ];

  nativeCheckInputs = [
    ceph
    restic
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
    description = "A restic repository backend that stores data in raw Ceph RADOS";
    homepage = "https://github.com/josh/restic-rados-server";
    license = lib.licenses.mit;
    inherit (ceph.meta) platforms;
    mainProgram = "restic-rados-server";
  };
})
