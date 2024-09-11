{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
}:

buildGoModule {
  pname = "packwiz";
  version = "0-unstable-2024-08-28";

  src = fetchFromGitHub {
    owner = "packwiz";
    repo = "packwiz";
    rev = "0bb89a4872d8dc2c45af251345ee780cab7ab9ad";
    sha256 = "sha256-LNKAyIPJSa3RddXRP912eZjLT6+r1wISKEXFHpZdavY=";
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
