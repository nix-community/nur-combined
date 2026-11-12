{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "settuings";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "settuings";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j5lY0pdQmKQmZ+PYioa9rYxPS8SUENar5rSWdbBLY9c=";
  };

  vendorHash = "sha256-EPbAZPJ0ZdfKqS7JNvjfRkdhRKD5F+epqBpOrPoT3S4=";

  subPackages = ["cmd/settuings"];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  nativeBuildInputs = [installShellFiles];

  postInstall = ''
    installShellCompletion --cmd settuings \
      --bash <($out/bin/settuings completion bash) \
      --zsh <($out/bin/settuings completion zsh) \
      --fish <($out/bin/settuings completion fish)
  '';

  nativeInstallCheckInputs = [versionCheckHook];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/settuings";
  versionCheckProgramArg = "--version";

  meta = {
    description = "TUI to manage Linux system settings like wifi and bluetooth, without leaving the terminal";
    homepage = "https://github.com/anotherhadi/settuings";
    changelog = "https://github.com/anotherhadi/settuings/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        name = "Hadi";
        github = "anotherhadi";
        githubId = 112569860;
      }
    ];
    mainProgram = "settuings";
  };
})
