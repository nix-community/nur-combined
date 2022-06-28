{
  description = "My personal NUR repository";

  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = builtins.attrValues (import ./overlays.nix);
        };
        repo = import ./. { inherit pkgs; };
    in {
      packages = {
        inherit (repo) lmt build-sh carapace-bin;
        inherit (pkgs) awesome-master nheko-master mtxclient-master;
      };
    }) // {
      overlays = import ./overlays.nix;
    };
}
