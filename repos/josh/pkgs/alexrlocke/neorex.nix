{
  lib,
  stdenv,
  fetchFromGitHub,
  neovim-unwrapped,
  # nixos-26.05 predates Zig 0.17
  zig_0_17 ? null,
  nix-update-script,
  runCommand,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "neorex";
  version = "0-unstable-2026-11-01";

  src = fetchFromGitHub {
    owner = "alexrlocke";
    repo = "neorex";
    rev = "13733b66a1f56aae9f90932ca90012a9a3cebeb9";
    hash = "sha256-B5jQbmySJsLAtakt1AXGNQP4uLIjAcdjsOcmNN13/Kg=";
  };

  nativeBuildInputs = [
    zig_0_17.hook
  ];

  nativeCheckInputs = [
    neovim-unwrapped
  ];

  doCheck = true;

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
