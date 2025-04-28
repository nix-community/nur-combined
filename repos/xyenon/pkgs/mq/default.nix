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
  version = "0.1.2-unstable-2025-04-27";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "fa25e6f2a77cf71da0596e910ed7b919f9cbcf19";
    hash = "sha256-SBHmGSEwDXRoJw57l3hEkTi8GeFcEbmbHnw9jvt9S2I=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-tKCgrmEbnHR9rdWEOEozcZM9hXY6HTkiYVv1Hs/DuGc=";

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
