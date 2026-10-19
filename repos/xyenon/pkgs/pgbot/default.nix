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
    hash = "sha256-nZmjgdDNQXhti8S7f3hbqgCUTazx8E+SIj5H/etwuSA=";
  };

  vendorHash = "sha256-k9B4GXk5QJOag6hK/zApybCyLZO4Z8HeW8ec7edRBKo=";

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
