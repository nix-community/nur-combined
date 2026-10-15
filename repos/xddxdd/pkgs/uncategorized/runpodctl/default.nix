{
  fetchFromGitHub,
  lib,
  buildGo127Module,
  nix-update-script,
}:

buildGo127Module (finalAttrs: {
  pname = "runpodctl";
  version = "3.0.1";
  src = fetchFromGitHub {
    owner = "runpod";
    repo = "runpodctl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YXtdlX+HbPEp0LuZqYHxns6WpPydrS/Qsf7SjZ9kSqo=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  vendorHash = "sha256-Csrq2LotNk+kdcz3wjWL2aMIY1PRdLUKrtAChHFk09E=";

  postFixup = ''
    rm -f $out/bin/docs
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/runpod/runpodctl/releases/tag/v${finalAttrs.version}";
    description = "RunPod CLI for pod management";
    homepage = "https://www.runpod.io";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "runpodctl";
  };
})
