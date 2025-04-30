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
  version = "0.1.2-unstable-2025-04-29";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "05b0908fab2c7a6b401018a8cf0ef65495e4665b";
    hash = "sha256-C7Ai9rnvIxnIcCksQi0QiXzDhDejj8bqtMS/K/3p8aM=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-l2dxU0V+2HYXtS2wGd1XWWyml2tHYE/7B2c7/Yuj0oI=";

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
