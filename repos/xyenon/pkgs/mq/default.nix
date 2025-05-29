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
  version = "0.1.6-unstable-2025-05-25";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "446f9742ddca7943d9d0de9c096c5f964ad3176f";
    hash = "sha256-IObdq/sERiTS0v/gePItktqrZfObIHB9NyRDziEnOqU=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-mvXfQIa8GqPApq2AARK2YYAF9TStAP7bTChWTEMJC14=";

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
