{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
}:
buildGoModule rec {
  pname = "cheatmd";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "cheatmd-dev";
    repo = "cheatmd";
    rev = "v${version}";
    hash = "sha256-939bFkzQcaUH7J8l+C0CkooCvV15MRmYmpOnRgei4LQ=";
  };

  vendorHash = "sha256-C3E64LYi5ReqQT9WcN8KFhi3oUkenfXf/1Y/s/sb4Mg=";

  subPackages = ["cmd/cheatmd"];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${version}"
  ];

  nativeBuildInputs = [installShellFiles];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd cheatmd \
      --bash <($out/bin/cheatmd completion bash) \
      --fish <($out/bin/cheatmd completion fish) \
      --zsh <($out/bin/cheatmd completion zsh)
  '';

  meta = with lib; {
    description = "Executable Markdown cheatsheets";
    homepage = "https://github.com/cheatmd-dev/cheatmd";
    changelog = "https://github.com/cheatmd-dev/cheatmd/releases/tag/v${version}";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [
      {
        name = "Hadi";
        github = "anotherhadi";
        githubId = 112569860;
      }
    ];
    mainProgram = "cheatmd";
  };
}
