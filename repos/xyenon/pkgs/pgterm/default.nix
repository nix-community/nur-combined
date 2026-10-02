{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  pgbot,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "pgterm";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "pgrundev";
    repo = "pgterm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rU2je/EOyLU0O1HUafqnwLBN2W+cWfUo3KYx8qsN3OU=";
  };

  cargoHash = "sha256-GwbXwhmqLXdNKYq55ShzYWILZvQde1gaKbHESjWasEY=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    rm $out/bin/fake-pgbot
    wrapProgram $out/bin/pgterm \
      --prefix PATH : ${lib.makeBinPath [ pgbot ]}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Multi-database terminal UI for PostgreSQL powered by pgbot";
    homepage = "https://pgterm.dev";
    changelog = "https://github.com/pgrundev/pgterm/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xyenon ];
    mainProgram = "pgterm";
  };
})
