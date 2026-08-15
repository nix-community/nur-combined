{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ceph,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "ceph-mgr-endpoint-controller";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "ceph-mgr-endpoint-controller";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ThezipeWYG/hUHkFx2TjAHoi1Z9Vqm2HTX6dtWj7fSo=";
  };

  vendorHash = "sha256-QWjN2fIUOSz05lIp3ywRDIS5YBuY+LUHKavi1r0FXYk=";

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
