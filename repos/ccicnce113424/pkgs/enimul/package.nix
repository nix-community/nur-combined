{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "enimul";
  version = "0.7.4";
  src = fetchFromGitHub {
    owner = "lzpls";
    repo = "enimul";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DmQfK8s4Q8SuV3jB2PbteyoRpgsiAILc74KUbRLPI+Y=";
  };

  vendorHash = "sha256-MdklXynEG8VWOcsAwgqRz556McYoN0XSh9FrzQseiT0=";

  tags = [ "nodebug" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Lightweight local proxy server that protects TLS connections over TCP";
    homepage = "https://github.com/lzpls/enimul";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "enimul";
  };
})
