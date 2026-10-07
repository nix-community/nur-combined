{
  buildGo127Module,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGo127Module (finalAttrs: {
  pname = "flapalerted";
  version = "4.6.0";
  src = fetchFromGitHub {
    owner = "Kioubit";
    repo = "FlapAlerted";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7uK8d0XLSYRWHmw7wMxJsNpefdJTdzWWc5/lavz1vjM=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  vendorHash = null;

  patches = [ ./roaFilter-onstart.patch ];

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
