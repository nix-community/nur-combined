{
  lib,
  buildGo127Module,
  fetchFromGitHub,
  nix-update-script,
}:

buildGo127Module (finalAttrs: {
  pname = "tuios";
  version = "0.12.1";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Gaurav-Gosain";
    repo = "tuios";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MNjEA96Oo9Com09wltA/SnrJaXevC2zrq+QwhlVcd38=";
  };

  modBuildPhase = ''
    runHook preBuild
    go work vendor
    runHook postBuild
  '';

  vendorHash = "sha256-03oDCDvkXHMXcaZv7F7t3bUxPBN8qjdXXhNbejs+acc=";

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
    "-X=main.commit=${finalAttrs.src.rev}"
    "-X=main.date=1970-01-01T00:00:00Z"
    "-X=main.builtBy=goreleaser"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal window manager";
    homepage = "https://github.com/Gaurav-Gosain/tuios";
    changelog = "https://github.com/Gaurav-Gosain/tuios/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    platforms = lib.platforms.linux;
    mainProgram = "tuios";
  };
})
