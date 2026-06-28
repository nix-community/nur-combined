{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "jenkins-cli";
  version = "0.0.35";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "avivsinai";
    repo = "jenkins-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PY1VC/fEnodXGHyrhbJqMOmfB8muhbpA6qfzJ4ld2Gk=";
  };

  vendorHash = "sha256-nVHIZbbVoy2PWD2liRrXaQ7tIISmz8pE+nCzos9F6K8=";

  subPackages = [ "cmd/jk" ];

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/avivsinai/jenkins-cli/internal/build.versionFromLdflags=${finalAttrs.version}"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd jk \
      --bash <($out/bin/jk completion bash) \
      --fish <($out/bin/jk completion fish) \
      --zsh <($out/bin/jk completion zsh)
  '';

  meta = {
    description = "GitHub-style CLI for Jenkins";
    homepage = "https://github.com/avivsinai/jenkins-cli";
    license = lib.licenses.mit;
    mainProgram = "jk";
    maintainers = [ lib.maintainers.sikmir ];
  };
})
