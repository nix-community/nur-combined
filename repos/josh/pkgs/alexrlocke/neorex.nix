{
  lib,
  stdenv,
  fetchFromGitHub,
  # nixos-26.05 predates Zig 0.17
  zig_0_17 ? null,
  nix-update-script,
  runCommand,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "neorex";
  version = "0.1.0-unstable-2026-11-18";

  src = fetchFromGitHub {
    owner = "alexrlocke";
    repo = "neorex";
    rev = "546608b6e8271e0cc8938426206282d482907083";
    hash = "sha256-/7H4Q9LeR9Z6kBQdbkmH2XE34hHHGmKHUEYTltz4r+Q=";
  };

  nativeBuildInputs = [
    zig_0_17.hook
  ];

  # Upstream tests need git, ripgrep, a writable HOME and a git checkout
  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    help = runCommand "test-neorex-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; } ''
      neorex help
      touch $out
    '';
  };

  meta = {
    description = "Rex-native frontend for Neovim";
    homepage = "https://github.com/alexrlocke/neorex";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "neorex";
    broken = zig_0_17 == null;
  };
})
