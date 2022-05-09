{
  description = "My personal NUR repository";

  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (system: 
    let 
      pkgs = import nixpkgs { inherit system; };
      repo = import ./. { inherit pkgs; };
    in {
      packages = { inherit (repo) lmt build-sh carapace-bin; };
    }) // { 
      overlays = import ./overlays.nix;
    };
}
