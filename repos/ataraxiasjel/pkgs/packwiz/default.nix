{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
}:

buildGoModule {
  pname = "packwiz";
  version = "0-unstable-2024-10-14";

  src = fetchFromGitHub {
    owner = "packwiz";
    repo = "packwiz";
    rev = "0626c00149a8d9a5e9f76e5640e7b8b95c064350";
    sha256 = "sha256-eAGfLUcyjDR2oJjLK3+DiuICTqoOcIwO5wL350w6vGw=";
  };

  vendorHash = "sha256-krdrLQHM///dtdlfEhvSUDV2QljvxFc2ouMVQVhN7A0=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd packwiz \
      --bash <($out/bin/packwiz completion bash) \
      --fish <($out/bin/packwiz completion fish) \
      --zsh <($out/bin/packwiz completion zsh)
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = with lib; {
    description = "A command line tool for editing and distributing Minecraft modpacks, using a git-friendly TOML format";
    homepage = "https://packwiz.infra.link/";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    mainProgram = "packwiz";
  };
}
