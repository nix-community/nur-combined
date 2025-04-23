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
  version = "0.1.1-unstable-2025-04-22";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "f2c3bd6d9d44173a0d37da3c502dfd28c7b2b50f";
    hash = "sha256-clGAQ6OplDnIewmcmTvd1LsLddlVuC3Ku2Hs07RalXI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-wNU/sTs6riymdqj9ENJtfNi+xhzegeifs6ML6UiTGow=";

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
