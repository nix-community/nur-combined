{
  lib,
  buildGo127Module,
  fetchFromGitea,

  git,
  installShellFiles,

  nix-update-script,
  runCommand,
  testers,
}:
buildGo127Module (finalAttrs: {
  pname = "gitea-cli";
  version = "0.1.0";

  src = fetchFromGitea {
    domain = "gitea.com";
    owner = "gitea";
    repo = "cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-MhEuA0H3igq/kFbFu2DOM/uBt6dwB0lAgNcocfjF/e0=";
  };

  vendorHash = "sha256-c4bIx01OpX50armY/9gEhJCFqGcskivRLcVOShk6tO8=";

  nativeBuildInputs = [ installShellFiles ];
  nativeCheckInputs = [ git ];

  env.CGO_ENABLED = 0;
  subPackages = [ "cmd/gt" ];
  ldflags = [
    "-s"
    "-w"
    "-X gitea.dev/cli/internal/version.Version=${finalAttrs.version}"
  ];

  postBuild = ''
    go run ./tools/cli-docs --out docs/generated
  '';

  checkPhase = ''
    runHook preCheck
    export GOFLAGS=''${GOFLAGS//-trimpath/}
    # Transport tests use short deadlines; avoid contention between test packages.
    go test -p 1 ./...
    runHook postCheck
  '';

  postInstall = ''
    installManPage docs/generated/man/*.1
    installShellCompletion --cmd gt \
      --bash docs/generated/completion/gt.bash \
      --fish docs/generated/completion/gt.fish \
      --zsh docs/generated/completion/_gt
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      command = "gt version";
    };
    help = runCommand "test-gitea-cli-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; } ''
      export HOME="$TMPDIR"
      gt --help
      gt repo --help
      test -s ${finalAttrs.finalPackage}/share/man/man1/gt.1.gz
      test -s ${finalAttrs.finalPackage}/share/bash-completion/completions/gt.bash
      test -s ${finalAttrs.finalPackage}/share/fish/vendor_completions.d/gt.fish
      test -s ${finalAttrs.finalPackage}/share/zsh/site-functions/_gt
      touch $out
    '';
  };

  meta = {
    description = "Command-line interface for Gitea";
    homepage = "https://gitea.com/gitea/cli";
    changelog = "https://gitea.com/gitea/cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "gt";
  };
})
