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
  version = "0-unstable-2025-04-04";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "0bcdee8fc252692b5bd511d1da238e93ba4add4e";
    hash = "sha256-TsvcZMrccyRjTP0Lnl4IvFPImLbZmIK5AMaM0cxl5T8=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-7pkROxPMybPON48n5ZBOE4woqU+YQ2olU8d4Fomi2J4=";

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
