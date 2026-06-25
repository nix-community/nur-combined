# Regression test: patchedDependenciesToOverrides must handle scoped packages
# whose names and patch file paths contain '@' and '/'.
# See: https://github.com/nix-community/bun2nix/issues/70
# See: https://github.com/nix-community/bun2nix/issues/73
{
  bun2nix,
  lib,
  ...
}:
let
  src = ./.;
  packageJsonContents = lib.importJSON ./package.json;
  patchedDependencies = lib.mapAttrs (_: path: "${src}/${path}") (
    packageJsonContents.patchedDependencies or { }
  );
  patchOverrides = bun2nix.patchedDependenciesToOverrides {
    inherit patchedDependencies;
  };
in
bun2nix.mkDerivation {
  packageJson = ./package.json;

  inherit src;

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
    overrides = patchOverrides;
  };

  buildPhase = ''
    bun run index.ts
  '';

  installPhase = ''
    echo "Scoped patch test passed!" > $out
  '';
}
