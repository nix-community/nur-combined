{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "settuings";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "settuings";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Vpkzs84NSerl/7QDIWGNUDuKCXc7A/dkCglaTV2idGM=";
  };

  vendorHash = "sha256-BndE5rJ33aARDmoJPu/POxSsnezXg2D1GC23VGz0IWQ=";

  subPackages = ["cmd/settuings"];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/anotherhadi/settuings/internal/config.Version=${finalAttrs.version}"
  ];

  nativeInstallCheckInputs = [versionCheckHook];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/settuings";
  versionCheckProgramArg = "--version";

  meta = {
    description = "TUI to manage Linux system settings like wifi and bluetooth, without leaving the terminal";
    homepage = "https://github.com/anotherhadi/settuings";
    changelog = "https://github.com/anotherhadi/settuings/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        name = "Hadi";
        github = "anotherhadi";
        githubId = 112569860;
      }
    ];
    mainProgram = "settuings";
  };
})
