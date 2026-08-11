{ bun2nix, ... }:
bun2nix.mkDerivation {
  packageJson = ./package.json;

  src = ./.;

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;

    # Pass credential configuration files for private registry auth
    # These are optional - only needed if your bun.lock references
    # packages from private registries
    bunfigPath = ./bunfig.toml;

    # Alternatively (or additionally), you can use .npmrc:
    # npmrcPath = ./.npmrc;
  };
}
