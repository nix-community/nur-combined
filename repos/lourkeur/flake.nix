{
  description = "My humble additions to the NUR";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.simpleFlake {
      inherit self nixpkgs;
      name = "nur-expressions";
      overlay = ./overlay.nix;
    };
}
