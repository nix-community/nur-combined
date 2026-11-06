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
  version = "0-unstable-2026-11-05";

  src = fetchFromGitHub {
    owner = "alexrlocke";
    repo = "neorex";
    rev = "b9b97dd72e145b08e5003578b2b3091117faa98b";
    hash = "sha256-lFD0TQVf/TQvYYnSCpNixmARE2xMTyB+J4ZNxlKFoJA=";
  };

  # Fail in the Nix sandbox
  postPatch = ''
    substituteInPlace src/nvim/windows.zig \
      --replace-fail \
        "test \"a window Neovim resizes itself snaps back to its pane's size\" {" \
        "test \"a window Neovim resizes itself snaps back to its pane's size\" { if (true) return error.SkipZigTest;" \
      --replace-fail \
        "test \"a window Neovim resizes asks for its pane to be resized\" {" \
        "test \"a window Neovim resizes asks for its pane to be resized\" { if (true) return error.SkipZigTest;"
  '';

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
