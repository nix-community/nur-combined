{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "default-creds-tui";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "default-creds-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4sw+p3ono/VOtwK6A0q/KDidcdgq+FOVi3WGXYWcCRg=";
  };

  vendorHash = "sha256-vGunjcvAjh2DZSxgvTcAKOvyoj78AyJVafExNuz3sec=";

  subPackages = ["cmd/default-creds-tui"];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/anotherhadi/default-creds-tui/internal/config.Version=${finalAttrs.version}"
  ];

  nativeInstallCheckInputs = [versionCheckHook];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/default-creds-tui";
  versionCheckProgramArg = "--version";

  meta = {
    description = "Search factory-set default credentials, without leaving the terminal";
    homepage = "https://github.com/anotherhadi/default-creds-tui";
    changelog = "https://github.com/anotherhadi/default-creds-tui/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [
      {
        name = "Hadi";
        github = "anotherhadi";
        githubId = 112569860;
      }
    ];
    mainProgram = "default-creds-tui";
  };
})
