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
  version = "0.5.2";
  src = fetchFromGitHub {
    owner = "afjcjsbx";
    repo = "picoclaw";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wJycKB+QN9SepgxMFWk+fJsBJpYgrvawMtHYton4KUg=";
  };
  __structuredAttrs = true;
  strictDeps = true;

  vendorHash = "sha256-H4EnmzjuP7u3tAHu9azsK3nrSsWWEnYF35R/0xipzXc=";

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
