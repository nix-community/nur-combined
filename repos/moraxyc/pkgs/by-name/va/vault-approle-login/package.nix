{
  lib,
  buildGoModule,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "vault-approle-login";
  version = "1.0.0";

  src = ./.;

  vendorHash = null;

  ldflags = [
    "-s"
    "-X main.version=${finalAttrs.version}"
  ];

  doInstallCheck = true;
  nativeCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-version";

  meta = {
    description = "Simple CLI tool to login to Vault using AppRole.";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "vault-approle-login";
  };
})
