{
  fetchFromGitHub,
  lib,
  buildGo127Module,
  nix-update-script,
}:

buildGo127Module (finalAttrs: {
  pname = "runpodctl";
  version = "3.1.1";
  src = fetchFromGitHub {
    owner = "runpod";
    repo = "runpodctl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-09EOqntCGEuOKiWceiT1gfAQ4du0zMoFg20KrmQLgZ4=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  vendorHash = "sha256-M7eyEoE9FAGZvHvIwrvVYyDCcyYxnn7bWBTOBDRl7aU=";

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
