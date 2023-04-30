{
  description = "NUR packages";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, flake-utils, nixpkgs }:
    {
      overlay = final: prev: {
        dschrempf = self.packages.${final.system};
      };
    } //
    flake-utils.lib.eachDefaultSystem
      (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          packages = import ./default.nix { inherit pkgs; inherit system; };
        }
      );
}
