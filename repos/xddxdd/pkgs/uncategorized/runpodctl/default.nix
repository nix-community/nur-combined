{
  fetchFromGitHub,
  lib,
  buildGo127Module,
  nix-update-script,
}:

buildGo127Module (finalAttrs: {
  pname = "runpodctl";
  version = "2.14.0";
  src = fetchFromGitHub {
    owner = "runpod";
    repo = "runpodctl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TFUEc6mZSE5FC++fuF7fn3bzAlo+q4glj9LkOLSTb64=";
  };
  vendorHash = "sha256-TZrffoC4He+ltwDkDS+6/eqA4/Pv8+BtG+kZbDHb6Fw=";

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
