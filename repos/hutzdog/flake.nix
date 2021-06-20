{
  description = "My personal NUR repository";

  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (system: 
    let pkgs = import nixpkgs { inherit system; };
    in {
      packages = import ./default.nix { inherit pkgs; };
    });
}
