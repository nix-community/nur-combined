{
  buildGo127Module,
  fetchFromGitHub,
  lib,
  nix-update-script,
  olm,
  versionCheckHook,
}:

buildGo127Module (finalAttrs: {
  pname = "picoclaw";
  version = "0.5.3";
  src = fetchFromGitHub {
    owner = "afjcjsbx";
    repo = "picoclaw";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DmIX78J7r/5jW64oB0WfmK0aRhkJyIvg3kDcPm8FK7A=";
  };
  __structuredAttrs = true;
  strictDeps = true;

  vendorHash = "sha256-rL9qbF9VpMaI5kb4aByfWs3XucHVYySJmWQCnA+eO8I=";

  buildInputs = [ olm ];
  subPackages = [ "cmd/picoclaw" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sipeed/picoclaw/pkg/config.Version=${finalAttrs.version}"
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "version";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^v([0-9.]+)$"
    ];
  };

  meta = {
    changelog = "https://github.com/afjcjsbx/picoclaw/releases/tag/v${finalAttrs.version}";
    description = "Lightweight personal AI assistant and agent gateway";
    homepage = "https://github.com/afjcjsbx/picoclaw";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "picoclaw";
    platforms = lib.platforms.unix;
  };
})
