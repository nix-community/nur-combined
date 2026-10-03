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
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "pgrundev";
    repo = "pgterm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5btrdsaYNgUSXrQKqYBnkkXElG63mNc/3R2ALyj0Cx8=";
  };

  cargoHash = "sha256-xZ4ldyUDMijZP4j5Sz0rsyY5BGVOXMTztRMS/n7VOzc=";

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
