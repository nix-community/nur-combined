{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "drop";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "wrr";
    repo = "drop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Us5UOrFDRmSmZb+cBUcoA0TT1KboCnX6mTSlLb9DKWM=";
  };

  vendorHash = "sha256-JeheKUngdDI/9X1tDpw7seD7XirnvdBbcyvRzM2I7Gs=";

  env.CGO_ENABLED = 0;

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  versionCheckKeepEnvironment = "HOME";
  doInstallCheck = true;

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.Version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Linux sandboxing that doesn't get in your way";
    homepage = "https://github.com/wrr/drop";
    license = lib.licenses.asl20;
    mainProgram = "drop";
    maintainers = with lib.maintainers; [ nagy ];
    platforms = lib.platforms.linux;
  };
})
