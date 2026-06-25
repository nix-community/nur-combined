{ bun2nix, ... }:
bun2nix.mkDerivation {
  packageJson = ./package.json;

  src = ./.;

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
  };
}
