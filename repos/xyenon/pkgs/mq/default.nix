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
  version = "0-unstable-2025-04-10";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "82f9c83be1c63f813e406f2d0d9be492c3177cf7";
    hash = "sha256-excDxpPOin0VsXfEFqyrIXhb9AznZIgDE5jZ7C/nRiQ=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-wdu83dPMoeGZ5A+G6714wdrJWqpWeYRmXPSbXodXqQg=";

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
