{
  description = "crimsonvariable packages for the Nix User Repository";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      packages = import ./default.nix { inherit pkgs; };
    in
    {
      legacyPackages.${system} = packages;
      packages.${system} = packages // {
        default = packages.ff00-vwm;
      };
      checks.${system}.ff00-vwm = packages.ff00-vwm;
      formatter.${system} = pkgs.nixfmt-tree;
    };
}
