{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "npr";
  version = "0-unstable-2026-11-20";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "npr";
    rev = "fb7897a9056cd80c62da972e9b60318fe4362158";
    hash = "sha256-nCjorsU81DaHrHNhlXI44rkz3ho/9XOFeRoqEVmLGAY=";
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
