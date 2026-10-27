{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "kube-ups-taint";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "kube-ups-taint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Imutgz+e+7ndWM3eUaZbgTsgdTjVFUNx8mwV1hxJWIE=";
  };

  vendorHash = "sha256-boZ+eItwmmkb0P/ax2BbgV+2j8G38at40huz/uI/sas=";

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
