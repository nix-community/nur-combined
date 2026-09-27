{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "flapalerted";
  version = "4.5.1";
  src = fetchFromGitHub {
    owner = "Kioubit";
    repo = "FlapAlerted";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SEXiD/PVqlCozQPBlCKbLmdXueyQsCjc2Fsmhy4r5qI=";
  };
  vendorHash = null;

  tags = [
    "mod_httpAPI"
    "mod_log"
    "mod_roaFilter"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/Kioubit/FlapAlerted/releases/tag/v${finalAttrs.version}";
    mainProgram = "FlapAlerted";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "BGP Update based flap detection";
    homepage = "https://github.com/Kioubit/FlapAlerted";
    license = lib.licenses.unfree;
  };
})
