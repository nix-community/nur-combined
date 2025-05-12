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
  version = "0.1.4-unstable-2025-05-11";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "565614a65873610028a6fcc3e5039d262ab71656";
    hash = "sha256-7+wbr+hOczplyJCc3As4I1iXiBNYqPQxf2A8vzJNPoA=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-Qatz6gtfZMaoS/c9PJWBxpt5PUmzZEik65dYfKOV2sk=";

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
