{
  lib,
  buildGo127Module,
  fetchFromGitea,
  nix-update-script,
  testers,
}:
buildGo127Module (finalAttrs: {
  pname = "gitea-runner";
  version = "6.0.0";

  src = fetchFromGitea {
    domain = "gitea.com";
    owner = "gitea";
    repo = "runner";
    rev = "v${finalAttrs.version}";
    hash = "sha256-UOOvw1R9CtHlDlo8n8Racw4qEAv/KU8tToW4Cc1M0zg=";
  };

  vendorHash = "sha256-v8ihlWuqI4A/FoexyZkzElgLJS8OEHwtWz2vytf3nqk=";

  env.CGO_ENABLED = 0;
  subPackages = [ "." ];
  ldflags = [
    "-s"
    "-w"
    "-X gitea.com/gitea/runner/internal/pkg/ver.version=v${finalAttrs.version}"
  ];

  postInstall = ''
    mv $out/bin/runner $out/bin/gitea-runner
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
    version = "v${finalAttrs.version}";
  };

  meta = {
    description = "Runner for Gitea Actions";
    homepage = "https://gitea.com/gitea/runner";
    changelog = "https://gitea.com/gitea/runner/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "gitea-runner";
  };
})
