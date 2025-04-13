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
  version = "0.1.0-unstable-2025-04-13";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "92b24dcb3d3e5052ed5e77c65ddb3c6e5bbbcd62";
    hash = "sha256-RvXOtaQFNl84CrQFROlNX3zj7CxPvHfzFncHKakmXbI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-3JWgvLYG8vQU4feZWfIpSuJDVbAP4NGV3ix9yBM0Ivg=";

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
