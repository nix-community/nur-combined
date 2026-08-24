{
  fetchFromGitHub,
  lib,
  buildGo127Module,
  nix-update-script,
}:

buildGo127Module (finalAttrs: {
  pname = "runpodctl";
  version = "2.11.0";
  src = fetchFromGitHub {
    owner = "runpod";
    repo = "runpodctl";
    tag = "v2.11.0";
    hash = "sha256-h6QHFBTzyrjeAHp9m6qFM7aU9YiaCrMi3c2ofXM8lwg=";
  };
  vendorHash = "sha256-aCrN521urP1FioTmbcR1BNKg+OCith1mabyayuC9FtI=";

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
