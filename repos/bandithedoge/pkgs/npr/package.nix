{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "npr";
  version = "0-unstable-2026-11-03";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "npr";
    rev = "6a55992b154751190a1460225961fb31461ae630";
    hash = "sha256-EjIHvGvvCeWaMAh5FouOC0KuipIuy9FoXdcx/lsSu0I=";
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
