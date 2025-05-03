{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
  nix-update-script,
  rustc,
}:

rustPlatform.buildRustPackage {
  pname = "mq";
  version = "0.1.3-unstable-2025-05-02";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "f41d995a1635aa2769eaf9b93fa5f6099caedb39";
    hash = "sha256-ZKK1hC45FZpAL8J1X5KkKrgdAcy9f86mRDTpFw5E7mw=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-006ICCFjl6awPHC41I573FNoN96qfb/+hVfDlAzwSmI=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd mq \
      --bash <($out/bin/mq completion --shell bash) \
      --fish <($out/bin/mq completion --shell fish) \
      --zsh <($out/bin/mq completion --shell zsh)
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Jq like markdown processing tool";
    homepage = "https://github.com/harehare/mq";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
    mainProgram = "mq";
    broken = versionOlder rustc.version "1.85.0";
  };
}
