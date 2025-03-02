# See <https://github.com/pimalaya/neverest/blob/master/package.nix>
{
  lib,
  pkg-config,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  apple-sdk,
  installShellFiles,
  installShellCompletions ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
  installManPages ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
  notmuch,
  buildNoDefaultFeatures ? false,
  buildFeatures ? [ ],
  nix-update-script,
}:
rustPlatform.buildRustPackage rec {
  __structuredAttrs = true;

  pname = "neverest";
  version = "1.0.0-beta-unstable-2024-12-19";

  src = fetchFromGitHub {
    owner = "pimalaya";
    repo = "neverest";
    rev = "cc5f5214d3bea064ed059116ac81e40a803faa7e";
    hash = "sha256-MXQDy5b/ooSkISEVM9KxHeqkkhPimZJtX3j9jqTP5aU=";
  };

  cargoHash = "sha256-oQrbHYbsfPAVAe3UPawRg/GRTIytQZMcxZcwC8J1T/Y=";
  useFetchCargoVendor = true;

  inherit buildNoDefaultFeatures buildFeatures;

  nativeBuildInputs = [
    pkg-config
  ] ++ lib.optional (installManPages || installShellCompletions) installShellFiles;

  buildInputs =
    lib.optional stdenv.hostPlatform.isDarwin apple-sdk
    ++ lib.optional (builtins.elem "notmuch" buildFeatures) notmuch;

  doCheck = false;
  auditable = false;

  # unit tests only
  cargoTestFlags = [ "--lib" ];

  postInstall =
    ''
      mkdir -p $out/share/{completions,man}
    ''
    + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      "$out"/bin/neverest man "$out"/share/man
    ''
    + lib.optionalString installManPages ''
      installManPage "$out"/share/man/*
    ''
    + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      "$out"/bin/neverest completion bash > "$out"/share/completions/neverest.bash
      "$out"/bin/neverest completion elvish > "$out"/share/completions/neverest.elvish
      "$out"/bin/neverest completion fish > "$out"/share/completions/neverest.fish
      "$out"/bin/neverest completion powershell > "$out"/share/completions/neverest.powershell
      "$out"/bin/neverest completion zsh > "$out"/share/completions/neverest.zsh
    ''
    + lib.optionalString installShellCompletions ''
      installShellCompletion "$out"/share/completions/neverest.{bash,fish,zsh}
    '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = rec {
    description = "CLI to manage emails";
    mainProgram = "neverest";
    homepage = "https://github.com/pimalaya/neverest";
    changelog = "${homepage}/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ soywod ];
  };
}
