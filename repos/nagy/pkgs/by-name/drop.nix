{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "drop";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "wrr";
    repo = "drop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-h6o/FRXmvf8avcg3gHBgYtdoYoGTvg2K3XZzhy+1dnM=";
  };

  vendorHash = "sha256-hNJTug2fA7TCGJQW8vEuFtLPQieDndYdkiNO85AGNTE=";

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

  meta = {
    description = "Linux sandboxing that doesn't get in your way";
    homepage = "https://github.com/wrr/drop";
    license = lib.licenses.asl20;
    mainProgram = "drop";
    maintainers = with lib.maintainers; [ nagy ];
    platforms = lib.platforms.linux;
  };
})
