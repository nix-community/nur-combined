{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "kube-ups-taint";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "kube-ups-taint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LCaDRoPe2BtQtCPxrc5f9I1bkgSrbRZOKVKXnpYsD0s=";
  };

  vendorHash = "sha256-6Q0BDEzVn55TJ7ciiDIfDWzl7PuETnS64Pa9/9Papik=";

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Kubernetes controller that taints nodes when their UPS goes on battery";
    homepage = "https://github.com/josh/kube-ups-taint";
    license = lib.licenses.mit;
    mainProgram = "kube-ups-taint";
    platforms = lib.platforms.linux;
  };
})
