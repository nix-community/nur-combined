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
  version = "0.1.1-unstable-2025-04-20";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "0c88cc2124542a4a590071395ff4f23d28cc189b";
    hash = "sha256-B6G1VGXNpfldPFVHOuxYtz9tqHclEubchudsqMrUTf8=";
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
