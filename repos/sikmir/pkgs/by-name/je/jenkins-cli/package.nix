{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "jenkins-cli";
  version = "0.0.34";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "avivsinai";
    repo = "jenkins-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5xmcNyURbZvhj9PEb88l2tMi7+YChmj8dJnfdDDMvWY=";
  };

  vendorHash = "sha256-MpIvoL6h2YZpFfTPpEcu9GWTM7uAxROsFtI0z3MlEII=";

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
