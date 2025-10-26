{
  lib,
  buildGoModule,
  fetchFromGitHub,
  less,
  more,
  installShellFiles,
  testers,
  jira-cli-go,
  nix-update-script,
  ...
}:
buildGoModule rec {
  pname = "jira-cli-go";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "ankitpokhrel";
    repo = "jira-cli";
    rev = "eef7ae96c20a26f16b26f178c07ebe7df11511ab";
    hash = "sha256-E/pKVVQxSmUoX/oPXjdUt8NPTNn22zrlbGMK7yMlqjg=";
  };

  vendorHash = "sha256-Ndo6EQp/k9BLvIHf+NiBj6a73Th1liEnd5+ZGelV8VM=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/ankitpokhrel/jira-cli/internal/version.GitCommit=${src.rev}"
    "-X github.com/ankitpokhrel/jira-cli/internal/version.SourceDateEpoch=0"
    "-X github.com/ankitpokhrel/jira-cli/internal/version.Version=${version}"
  ];

  __darwinAllowLocalNetworking = true;

  nativeCheckInputs = [less more]; # Tests expect a pager in $PATH

  passthru = {
    tests.version = testers.testVersion {
      package = jira-cli-go;
      command = "jira version";
      inherit version;
    };
    updateScript = nix-update-script {};
  };

  nativeBuildInputs = [installShellFiles];
  postInstall = ''
    installShellCompletion --cmd jira \
      --bash <($out/bin/jira completion bash) \
      --fish <($out/bin/jira completion fish) \
      --zsh <($out/bin/jira completion zsh)

    $out/bin/jira man --generate --output man
    installManPage man/*
  '';

  meta = with lib; {
    description = "Feature-rich interactive Jira command line";
    homepage = "https://github.com/ankitpokhrel/jira-cli";
    changelog = "https://github.com/ankitpokhrel/jira-cli/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [bryanasdev000 anthonyroussel];
    platforms = platforms.all;
  };
}
