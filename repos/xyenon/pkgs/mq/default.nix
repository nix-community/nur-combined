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
  version = "0.1.6-unstable-2025-05-27";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "e8b2203ebd2bcbcf7425d1e494b0d7e6919ad8d4";
    hash = "sha256-ADmSkB2R15zRhn7BDoCnsLiQSVmWkb/nPOkPfqnZaRA=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-PC+EbZzp6U1N/xcLRVZn0m7a/08DfiuivuWWz7Ulnvo=";

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
