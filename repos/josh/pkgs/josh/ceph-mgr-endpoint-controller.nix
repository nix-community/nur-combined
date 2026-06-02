{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  ceph,
}:
buildGoModule (finalAttrs: {
  pname = "ceph-mgr-endpoint-controller";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "ceph-mgr-endpoint-controller";
    tag = "v${finalAttrs.version}";
    hash = "sha256-S76z7bIjXx0tAc3fOj9eu34wQsMiv12UK9sL3a6OWp8=";
  };

  vendorHash = "sha256-Gru9frs/B8Tl+mYMFlRav9JSmNCV62jcWYMKw2r8Yrg=";

  env.CGO_ENABLED = 1;

  ldflags = [
    "-s"
    "-w"
  ];

  buildInputs = [
    ceph
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Kubernetes controller for Ceph Manager service discovery";
    homepage = "https://github.com/josh/ceph-mgr-endpoint-controller";
    license = lib.licenses.mit;
    inherit (ceph.meta) platforms;
    mainProgram = "ceph-mgr-endpoint-controller";
  };
})
