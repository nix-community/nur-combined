{
  lib,
  stdenv,
  buildGoModule,
  installShellFiles,
  versionCheckHook,

  sources,
  source ? sources.revdiff,
}:

buildGoModule (finalAttrs: {
  inherit (source) pname version src;

  # Upstream commits vendor/ into the repository.
  vendorHash = null;

  subPackages = [ "app/revdiff" ];

  # Tests require a git working tree, which is unavailable in the Nix sandbox.
  doCheck = false;

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-X main.revision=${finalAttrs.version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd revdiff \
      --bash completions/revdiff.bash \
      --fish completions/revdiff.fish \
      --zsh completions/revdiff.zsh
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  meta = {
    description = "TUI for reviewing diffs, files, and documents with inline annotations";
    homepage = "https://github.com/umputun/revdiff";
    changelog = "https://github.com/umputun/revdiff/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "revdiff";
    platforms = with lib.platforms; linux ++ darwin;
  };
})
