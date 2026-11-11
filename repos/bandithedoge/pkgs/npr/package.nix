{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "npr";
  version = "0-unstable-2026-11-10";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "npr";
    rev = "f41af64484aa27f4a9f9e8ad0a3b41159d807f63";
    hash = "sha256-LjOfSF13a0hWL0BMv7W2DLyM2Xs8Gk0eiPCpZCnrZxw=";
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
