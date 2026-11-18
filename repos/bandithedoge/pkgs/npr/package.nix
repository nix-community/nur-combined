{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "npr";
  version = "0-unstable-2026-11-17";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "npr";
    rev = "63e952f7f3e8c9ee02c3077340d909681e285940";
    hash = "sha256-GQMEmB71EUdS3JggFcxnpAqCLyov/DBjXzpRK8vMOoE=";
  };
  cargoHash = "sha256-MEyZ4E0FExOqzpWbmJCqDv6/gboFAnlo1kjPAqfMUQk=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Pull request tracker for Nixpkgs";
    homepage = "https://github.com/manic-systems/npr";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "npr";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
