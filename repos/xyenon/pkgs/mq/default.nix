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
  version = "0.1.1-unstable-2025-04-26";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "161317fdce53e15420c210b05fd26e70479ef23a";
    hash = "sha256-c65k9UEjlcWlNG7aR9mgTzSZIfwnetnCkr/XTNgFcoA=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-+WT0x4aNHJgnrMeDA7bIyGv/KCSZ2oaN5mG8LV06GlM=";

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
