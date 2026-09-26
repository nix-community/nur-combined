{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "symseek";
  version = "0-unstable-2026-09-04";

  src = fetchFromGitHub {
    owner = "merrkry";
    repo = "symseek";
    rev = "9e544e5325a027e1908c75f9ae3fb36246c95d35";
    hash = "sha256-IS8PLIkfbChtQ0WuiS/mabpkxMaI5Y0ZqgdJK7YDKq4=";
  };

  cargoHash = "sha256-01frd9F7blm7cb2IQV6h+aOCnzYpZpp81CSERHEC5jA=";

  strictDeps = true;

  # The CLI test expects verbose output from the spawned binary.
  preCheck = ''
    export RUST_LOG=debug
  '';

  meta = {
    description = "Utility to trace symlinks recursively";
    homepage = "https://github.com/merrkry/symseek";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ merrkry ];
    mainProgram = "symseek";
  };
})
