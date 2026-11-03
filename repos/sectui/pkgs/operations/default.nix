{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "operations";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "sectui";
    repo = "operations";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9e05N1gVmGacz+/sannIuDRZ2BluZQjwoZRofiHBgWI=";
  };

  vendorHash = "sha256-AvrtpZkoGpRo08sV1QlIUYxacZaHNyC8CXB86kKEkr4=";

  subPackages = ["cmd/ops"];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  nativeBuildInputs = [installShellFiles];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ops \
      --bash <($out/bin/ops completions bash) \
      --fish <($out/bin/ops completions fish) \
      --zsh <($out/bin/ops completions zsh)
  '';

  nativeInstallCheckInputs = [versionCheckHook];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/ops";
  versionCheckProgramArg = "--version";

  meta = {
    description = "CyberChef-like data transformations from the terminal";
    homepage = "https://github.com/sectui/operations";
    changelog = "https://github.com/sectui/operations/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [
      {
        name = "Hadi";
        github = "anotherhadi";
        githubId = 112569860;
      }
    ];
    mainProgram = "ops";
  };
})
