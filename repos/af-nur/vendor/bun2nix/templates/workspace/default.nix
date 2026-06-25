{
  bun2nix,
  ...
}:
bun2nix.mkDerivation {
  pname = "workspace-test-app";
  version = "1.0.0";

  src = ./.;

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
  };

  module = "packages/app/index.js";
}
