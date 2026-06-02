# See <https://github.com/pimalaya/mirador/blob/master/package.nix>
{
  lib,
  pkg-config,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  apple-sdk,
  dbus,
  installShellFiles,
  installShellCompletions ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
  installManPages ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
  buildNoDefaultFeatures ? false,
  buildFeatures ? [ ],
  nix-update-script,
}:
let
  inherit (stdenv.hostPlatform) isLinux isAarch64;

  dbus' = dbus.overrideAttrs (old: {
    env = (old.env or { }) // {
      NIX_CFLAGS_COMPILE =
        (old.env.NIX_CFLAGS_COMPILE or "")
        # required for D-Bus on Linux AArch64
        + lib.optionalString (isLinux && isAarch64) " -mno-outline-atomics";
    };
  });
in
rustPlatform.buildRustPackage rec {
  __structuredAttrs = true;

  pname = "mirador";
  version = "root-unstable-2026-06-01";

  src = fetchFromGitHub {
    owner = "pimalaya";
    repo = "mirador";
    rev = "2b50652eb23f826d647b399d942df73c48691f2e";
    hash = "sha256-Mv3xznNsLKiXhcMBdaIgiMFpZvGwDr19vM8KD0kNSU0=";
  };

  cargoHash = "sha256-PBt9V7La1j3uruYARkzmYzysbZnN9jKIhPUGyY1KxGI=";

  inherit buildNoDefaultFeatures buildFeatures;

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optional (installManPages || installShellCompletions) installShellFiles;

  buildInputs = lib.optional stdenv.hostPlatform.isDarwin apple-sdk ++ lib.optional isLinux dbus';

  doCheck = false;
  auditable = false;

  # unit tests only
  cargoTestFlags = [ "--lib" ];

  postInstall = ''
    mkdir -p $out/share/{services,completions,man}
    cp assets/mirador@.service "$out"/share/services/
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    "$out"/bin/mirador manuals "$out"/share/man
  ''
  + lib.optionalString installManPages ''
    installManPage "$out"/share/man/*
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    "$out"/bin/mirador completions -d "$out"/share/completions bash elvish fish powershell zsh
  ''
  + lib.optionalString installShellCompletions ''
    installShellCompletion --cmd mirador \
      --bash "$out"/share/completions/mirador.bash \
      --fish "$out"/share/completions/mirador.fish \
      --zsh "$out"/share/completions/_mirador
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = rec {
    description = "CLI to watch mailbox changes";
    mainProgram = "mirador";
    homepage = "https://github.com/pimalaya/mirador";
    changelog = "${homepage}/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ soywod ];
  };
}
