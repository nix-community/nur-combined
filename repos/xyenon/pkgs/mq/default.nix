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
  version = "0-unstable-2025-03-29";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "57e2e99191388cb39f923fe1d4951527f1c63ac2";
    hash = "sha256-hQfIQPtRegZPkhslJjBIvGz62JQCDeBoTlQYeYMUp7k=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-a6dikvg8aLdzBWhQIjSO5jLcwCBzGmOr9QIEz/8IKYg=";

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
