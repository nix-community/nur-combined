{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule {
  pname = "ceph-mgr-ts-gateway";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "ceph-mgr-ts-gateway";
    rev = "8c7e0c629b43786ffb99aedfbe7925873f61e047";
    hash = "sha256-6pNSmIiEdk/F+h5KMU96Vj652W8ja3AcvZr2AQtJ8es=";
  };

  vendorHash = "sha256-Zjwgm+lftw070zkQQnm5fIg526gcyvNQBMhqziGkx84=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Ceph Manager Tailscale Gateway";
    homepage = "https://github.com/josh/ceph-mgr-ts-gateway";
    license = lib.licenses.mit;
    mainProgram = "ceph-mgr-ts-gateway";
  };
}
