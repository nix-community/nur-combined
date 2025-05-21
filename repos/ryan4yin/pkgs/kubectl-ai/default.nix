{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "kubectl-ai";
  version = "0.0.10";

  src = fetchFromGitHub {
    owner = "GoogleCloudPlatform";
    repo = "kubectl-ai";
    rev = "v${finalAttrs.version}";
    hash = "sha256-eoxKybV4Wijl1tJUx3SldCA8hxRh4VSCCqNrmlD2QAE=";
  };

  vendorHash = "sha256-pJA4DPSvvApW+8BPcY3ZjAjALfNrjWDAdWoiPvs0FiI=";

  # Build the main command
  subPackages = [ "cmd" ];

  postInstall = ''
    mv $out/bin/{cmd,kubectl-ai}
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.date=unknown"
  ];

  # Disable the automatic subpackage detection
  doCheck = false;

  meta = {
    description = "AI powered Kubernetes Assistant";
    homepage = "https://github.com/GoogleCloudPlatform/kubectl-ai";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ryan4yin ];
    mainProgram = "kubectl-ai";
  };
})
