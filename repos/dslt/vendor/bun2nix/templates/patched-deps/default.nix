{
  bun2nix,
  lib,
  ...
}:
let
  src = ./.;
  packageJsonPath = ./package.json;
  packageJsonContents = lib.importJSON packageJsonPath;
  patchedDependencies = lib.mapAttrs (_: path: "${src}/${path}") (
    packageJsonContents.patchedDependencies or { }
  );
  patchOverrides = bun2nix.patchedDependenciesToOverrides {
    inherit patchedDependencies;
  };
in
bun2nix.mkDerivation {
  packageJson = packageJsonPath;

  inherit src;

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
    overrides = patchOverrides;
  };

  # Verify the patch was applied by running the test script
  buildPhase = ''
    bun run index.ts
  '';

  installPhase = ''
    echo "Patch test passed!" > $out
  '';
}
