{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
}:

buildGoModule {
  pname = "packwiz";
  version = "0-unstable-2024-05-27";

  src = fetchFromGitHub {
    owner = "packwiz";
    repo = "packwiz";
    rev = "7b4be47578151c36e784306b36d251ec2590e50c";
    sha256 = "sha256-XBp8Xv55R8rhhsQiWnOPH8c3fCpV/yq41ozJDcGdWfs=";
  };

  vendorHash = "sha256-yL5pWbVqf6mEpgYsItLnv8nwSmoMP+SE0rX/s7u2vCg=";

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
