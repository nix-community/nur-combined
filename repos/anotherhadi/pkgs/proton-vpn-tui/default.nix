{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "proton-vpn-tui";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "proton-vpn-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kSvBMMX/eu/qXMtSye+wLaqSoanic7aEy1bPC2U5qdI=";
  };

  vendorHash = "sha256-3ckCVSM5kq7P+RwTLUNSXE433sIAxuSy7ijKnSUeSgI=";

  subPackages = ["cmd/proton-vpn-tui"];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/anotherhadi/proton-vpn-tui/internal/config.Version=${finalAttrs.version}"
  ];

  nativeInstallCheckInputs = [versionCheckHook];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/proton-vpn-tui";
  versionCheckProgramArg = "--version";

  meta = {
    description = "Minimal, keyboard-friendly TUI wrapper for protonvpn-cli";
    homepage = "https://github.com/anotherhadi/proton-vpn-tui";
    changelog = "https://github.com/anotherhadi/proton-vpn-tui/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [
      {
        name = "Hadi";
        github = "anotherhadi";
        githubId = 112569860;
      }
    ];
    mainProgram = "proton-vpn-tui";
  };
})
