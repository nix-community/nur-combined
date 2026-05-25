{
  lib,
  buildGoModule,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "bw-ssh-agent-filter";
  version = "1.0.0";

  src = ./.;

  vendorHash = "sha256-5qZ6R5+cHu7Br/f6a8gLKUiuQC8EiNIW7aduv+EJUCg=";

  ldflags = [
    "-s"
    "-X main.version=${finalAttrs.version}"
  ];

  doInstallCheck = true;
  nativeCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-version";

  # nix-update auto -u
  passthru.updateScript = ./update.sh;

  meta = {
    description = "SSH agent proxy for filtering and reordering Bitwarden SSH keys";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "bw-ssh-agent-filter";
  };
})
