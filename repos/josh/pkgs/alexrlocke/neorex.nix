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
  version = "0.2.0-unstable-2026-11-19";

  src = fetchFromGitHub {
    owner = "alexrlocke";
    repo = "neorex";
    rev = "dfcefefb4df12b95469781791416dc582eba3e20";
    hash = "sha256-UEaKRllZrYN12yGQnsqEI1n7HphQRiomckv+b+cG/Qk=";
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
