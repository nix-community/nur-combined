{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "npr";
  version = "0-unstable-2026-10-14";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "npr";
    rev = "37581d252755979182fa50b20745dd77ea6294bd";
    hash = "sha256-bwJw5Tbmp+9MV6/KpqBlRsWpA500Z/7k5/FmxrP5VvE=";
  };
  cargoHash = "sha256-sW23JW0r14MyhOlQTSXblIodT8bEakJUiDzYJ+PRV4k=";

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
