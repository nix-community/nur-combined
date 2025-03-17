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
  version = "0-unstable-2025-03-17";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "5a3f5491e7bda973d803a4037aeb14f1e1811280";
    hash = "sha256-zouYcWrbeDaieto5XCsBuS5XG+/HrP1Kon8eze4FOwg=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-EcJx5ktpBejIzf3d/SdSZ9AoWGMCEWuMo5+94e4LJ2k=";

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
