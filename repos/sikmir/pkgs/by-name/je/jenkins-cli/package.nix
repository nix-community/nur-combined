{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "jenkins-cli";
  version = "0.0.34-unstable-2026-05-29";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "avivsinai";
    repo = "jenkins-cli";
    rev = "d4d521a573c4d04fc049599fac3d23441e2442ab";
    hash = "sha256-AegjRFnE6kX9rGS9DyXvAoO2BCr//itRYHvljXzz0iM=";
  };

  vendorHash = "sha256-XKKCUeLVsz2uKlfo+ctGBsbIaIIbU0eDC2K4NfFfKlI=";

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
