{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "proxctl";
  version = "0.2.11";

  src = fetchFromGitHub {
    owner = "rvben";
    repo = "proxctl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HjJH6b5RoUZqcl1UEdkpirQtVU7ZpkZuvJUvqK4Ana8=";
  };

  cargoHash = "sha256-qC43NuZcmoFZcq4DwhPPb+Rc0y+OJcWS7yrmoCwKlNI=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd proxctl \
      --bash <($out/bin/proxctl completions bash) \
      --fish <($out/bin/proxctl completions fish) \
      --zsh <($out/bin/proxctl completions zsh)
  '';

  meta = with lib; {
    description = "CLI for Proxmox VE";
    homepage = "https://github.com/rvben/proxctl";
    changelog = "https://github.com/rvben/proxctl/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ bryanhonof ];
    platforms = platforms.unix;
    mainProgram = "proxctl";
  };
})
