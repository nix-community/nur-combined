{
  lib,
  buildGoLatestModule,
  fetchFromGitHub,
  versionCheckHook,
  nix-update-script,
}:

buildGoLatestModule (finalAttrs: {
  __structuredAttrs = true;

  pname = "pgbot";
  version = "1";

  src = fetchFromGitHub {
    owner = "pgrundev";
    repo = "pgbot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QJWJTSS92g7Ay2r5yckbRX5/JOUIBDTKGXpEzerZyKI=";
  };

  vendorHash = "sha256-iN6SE0ehjVVXkw8hHsUrCNXPV1Xchw6gxt92kVCQTV4=";

  subPackages = [ "cmd/pgbot" ];
  env.CGO_ENABLED = "0";
  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  checkPhase = ''
    runHook preCheck
    # Tests locate documentation and schemas relative to runtime.Caller paths.
    go test -trimpath=false ./...
    runHook postCheck
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "In-database observability for PostgreSQL";
    homepage = "https://pgbot.dev";
    changelog = "https://github.com/pgrundev/pgbot/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xyenon ];
    mainProgram = "pgbot";
  };
})
