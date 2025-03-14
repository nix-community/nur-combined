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
  version = "0-unstable-2025-03-14";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "6c67eef33e99eb27b6843188eb573a608d8a1b66";
    hash = "sha256-6nYkbVUP0XxUc4yM5q3Fy830UVjYmB5SDKixAGue9xQ=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-A6mLYxLDe90OnKjMY0h+7PlioaQ0vQ113wDWqa4KyzI=";

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
