{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
}:

buildGoModule {
  pname = "packwiz";
  version = "0-unstable-2024-09-24";

  src = fetchFromGitHub {
    owner = "packwiz";
    repo = "packwiz";
    rev = "811dbc6f908b2b34a41abeee1c39839a611dd701";
    sha256 = "sha256-38xPz5QAEWjQe3qLCGNAl92vBeNU013p75YpA4hFc7w=";
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
