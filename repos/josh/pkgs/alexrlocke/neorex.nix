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
  version = "0.1.0-unstable-2026-11-14";

  src = fetchFromGitHub {
    owner = "alexrlocke";
    repo = "neorex";
    rev = "6fdece3d77ac160d4898afb16bea4b6dbd32d548";
    hash = "sha256-H/jj9SY7jJZ3jIT6p6zFhboP7tbqwi9mGSryVkJPBIY=";
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
