{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ceph,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "ceph-mgr-endpoint-controller";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "ceph-mgr-endpoint-controller";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wy7mEecOLmSAViR1DI9E/I+AQcEbqqnvIxj77ETFOvQ=";
  };

  vendorHash = "sha256-AjUpEoLyDK96UxcJrnZleGcLkqgrLvNnFhevMVemckA=";

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
