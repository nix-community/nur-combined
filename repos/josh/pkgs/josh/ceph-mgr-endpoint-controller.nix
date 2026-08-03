{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ceph,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "ceph-mgr-endpoint-controller";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "ceph-mgr-endpoint-controller";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JYuvNQdUy2B6dZ1uROmuGFVks0eSYPWtGl9Od3ldCBo=";
  };

  vendorHash = "sha256-c8qkgDRVRnAF2fVsKCAppBoEHlLBb42zrqId4E+vbIU=";

  buildInputs = [
    ceph
  ];

  env.CGO_ENABLED = 1;

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Kubernetes controller for Ceph Manager service discovery";
    homepage = "https://github.com/josh/ceph-mgr-endpoint-controller";
    license = lib.licenses.mit;
    mainProgram = "ceph-mgr-endpoint-controller";
    inherit (ceph.meta) platforms;
  };
})
